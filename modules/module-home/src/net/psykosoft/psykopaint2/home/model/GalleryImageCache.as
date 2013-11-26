package net.psykosoft.psykopaint2.home.model
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageThumbnailSize;

	import org.osflash.signals.Signal;

	public class GalleryImageCache
	{
		public var thumbnailLoaded : Signal = new Signal(GalleryImageProxy, BitmapData);

		private var _proxies : Array;
		private var _bitmapDatas : Array;

		private var _minIndex : int;
		private var _maxIndex : int;
		private var _loadingIndex : int;

		public function GalleryImageCache()
		{
			_proxies = [];
			_bitmapDatas = [];
		}

		public function replaceCollection(collection : GalleryImageCollection) : void
		{
			stopCaching();

			var max : int = collection.index + collection.numTotalPaintings;
			removeCachedImageRange(_minIndex, collection.index);
			removeCachedImageRange(max, _maxIndex);

			addProxies(collection);

			_minIndex = collection.index;
			_maxIndex = max;

			cacheImages();
		}

		private function addProxies(collection : GalleryImageCollection) : void
		{
			for (var i : int = 0; i < collection.numTotalPaintings; ++i) {
				var imageProxy : GalleryImageProxy = collection.images[i];
				var index : int = imageProxy.index;
				_proxies[index] = imageProxy;
			}
		}

		private function stopCaching() : void
		{
			_proxies[_loadingIndex].cancelLoading();
		}

		private function onError() : void
		{
			trace ("Error loading image");
			_bitmapDatas[_loadingIndex] = null;
			cacheNext();
		}

		private function onComplete(bitmapData : BitmapData) : void
		{
			_bitmapDatas[_loadingIndex] = bitmapData;
			thumbnailLoaded.dispatch(bitmapData);
			cacheNext();
		}

		private function cacheNext() : void
		{
			// TODO: Should we put loading queue in a separate collection and sort it based on distance to centre element?
			if (++_loadingIndex <= _maxIndex) {
				if (_bitmapDatas[_loadingIndex])
					cacheNext();
				else
					_proxies[_loadingIndex].loadThumbnail(onComplete, onError, ImageThumbnailSize.LARGE);
			}
		}

		private function cacheImages() : void
		{
			_loadingIndex = _minIndex - 1;

			cacheNext();
		}

		private function removeCachedImageRange(start : int, end : int) : void
		{
			for (var i : uint = start; i < end; ++i) {
				if (_bitmapDatas[i]) _bitmapDatas[i].dispose();
				_bitmapDatas[i] = null;
				_proxies[i] = null;
			}
		}
	}
}
