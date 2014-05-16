package net.psykosoft.psykopaint2.home.model
{
	import flash.display.BitmapData;
	
	import away3d.core.managers.Stage3DProxy;
	import away3d.hacks.BitmapRectTexture;
	import away3d.hacks.RectTextureBase;
	import away3d.hacks.TrackedBitmapRectTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageThumbnailSize;
	
	import org.osflash.signals.Signal;

	public class GalleryImageCache
	{
		public var thumbnailLoaded : Signal = new Signal(GalleryImageProxy, RectTextureBase);
		public var thumbnailDisposed : Signal = new Signal(GalleryImageProxy);
		public var loadingComplete : Signal = new Signal();

		private var _proxies : Array;
		private var _textures : Array;

		private var _minIndex : int;
		private var _maxIndex : int;
		private var _loadingIndex : int;

		private var _stage3DProxy : Stage3DProxy;

		public function GalleryImageCache(stage3DProxy : Stage3DProxy)
		{
			_proxies = [];
			_textures = [];
			_stage3DProxy = stage3DProxy;
		}

		public function get proxies():Array
		{
			return _proxies;
		}

		public function clear() : void
		{
			stopCaching();
			removeCachedImageRange(_minIndex, _maxIndex);
			_minIndex = 0;
			_maxIndex = 0;
		}

		public function replaceCollection(collection : GalleryImageCollection) : void
		{
			stopCaching();

			var max : int = collection.index + collection.images.length;
			removeCachedImageRange(_minIndex, collection.index);
			removeCachedImageRange(max, _maxIndex);

			addProxies(collection);

			_minIndex = collection.index;
			_maxIndex = max;

			cacheImages();
		}

		private function addProxies(collection : GalleryImageCollection) : void
		{
			for (var i : int = 0; i < collection.images.length; ++i) {
				var imageProxy : GalleryImageProxy = collection.images[i];
				var index : int = imageProxy.index;
				_proxies[index] = imageProxy;
			}
		}

		private function stopCaching() : void
		{
			if (_proxies[_loadingIndex])
				_proxies[_loadingIndex].cancelLoading();
		}

		private function onError() : void
		{
			_textures[_loadingIndex] = null;
			cacheNext();
		}

		private function onComplete(bitmapData : BitmapData) : void
		{
			var texture : TrackedBitmapRectTexture = new TrackedBitmapRectTexture(bitmapData);
			texture.getTextureForStage3D(_stage3DProxy);
			if (_textures[_loadingIndex]) throw "Shouldn't assign more than once!";
			_textures[_loadingIndex] = texture;
			thumbnailLoaded.dispatch(_proxies[_loadingIndex], texture);
			cacheNext();
		}

		private function cacheNext() : void
		{
			// TODO: Should we put loading queue in a separate collection and sort it based on distance to centre element?
			if (++_loadingIndex < _maxIndex) {
				if (_textures[_loadingIndex])
					cacheNext();
				else
					_proxies[_loadingIndex].loadThumbnail(onComplete, onError, ImageThumbnailSize.MEDIUM);
			}
			else {
				loadingComplete.dispatch();
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
				if (_textures[i]) {
					thumbnailDisposed.dispatch(_proxies[i]);
					BitmapRectTexture(_textures[i]).dispose();
				}
				_textures[i] = null;
				_proxies[i] = null;
			}
		}

		public function getThumbnail(index : int) : Texture2DBase
		{
			return _textures[index];
		}
	}
}
