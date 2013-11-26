package net.psykosoft.psykopaint2.core.models
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class FileGalleryImageProxy extends GalleryImageProxy
	{
		// public for convenience, not accessible through views as interface anyway
		public var normalSpecularMapURL  : String;
		public var colorMapURL  : String;
		public var sourceThumbnailURL : String;
		public var thumbnailFilename : String;
		public var compositeFilename : String;

		private var _onComplete : Function;
		private var _onError : Function;
		private var _sizeHint : int;
		private var _paintingGalleryVO : PaintingGalleryVO;
		private static var _scaleDownMatrix : Matrix = new Matrix(.5, 0, 0, .5);

		private var _activeLoader : Object;

		public function FileGalleryImageProxy()
		{
		}

		override public function cancelLoading() : void
		{
			_onComplete = null;
			_onError = null;
			if (_activeLoader)
				_activeLoader.close();
			_activeLoader = null;
		}

		override public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			if (_onComplete != null) throw "Already loading!";
			_sizeHint = size;

			_onComplete = onComplete;
			_onError = onError;

			loadBitmapData(thumbnailFilename, onThumbLoadComplete, onLoadError);
		}

		override public function loadFullSizedComposite(onComplete : Function, onError : Function) : void
		{
			if (_onComplete != null) throw "Already loading!";
			_onComplete = onComplete;
			_onError = onError;

			loadBitmapData(compositeFilename, onCompositeLoadComplete, onLoadError);
		}

		private function loadBitmapData(filename : String, onComplete : Function, onError : Function) : void
		{
			var loader : Loader = new Loader();
			_activeLoader = loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			loader.load(new URLRequest(filename));
		}

		private function onThumbLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);

			var bitmapData : BitmapData = Bitmap(loader.content).bitmapData;
			if (_sizeHint == ImageThumbnailSize.SMALL) {
				var source : BitmapData = bitmapData;
				bitmapData = new BitmapData(source.width *.5, source.height *.5, false);
				bitmapData.drawWithQuality(source, _scaleDownMatrix, null, null, null, true, StageQuality.BEST);

				source.dispose();
			}

			callOnComplete(bitmapData);
		}

		private function onCompositeLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			callOnComplete(Bitmap(loader.content).bitmapData);
		}

		private function callOnComplete(data : Object) : void
		{
			// need to nullify before callback because loading needs to be possible again inside the callback
			var onComplete : Function = _onComplete;
			_onComplete = null;
			_onError = null;
			onComplete(data);
		}

		private function onLoadError(event : IOErrorEvent) : void
		{
			// need to nullify before callback because loading needs to be possible again
			var onError : Function = _onError;
			_onComplete = null;
			_onError = null;

			if (_paintingGalleryVO) _paintingGalleryVO.dispose();
			_paintingGalleryVO = null;

			onError();
		}

		override public function loadSurfaceData(onComplete : Function, onError : Function) : void
		{
			if (_onComplete != null) throw "Already loading!";
			if (_paintingGalleryVO) onComplete(_paintingGalleryVO);
			_paintingGalleryVO = new PaintingGalleryVO();
			_onComplete = onComplete;
			_onError = onError;
			loadBitmapData(colorMapURL, onColorMapComplete, onLoadError);
		}

		private function onColorMapComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			_paintingGalleryVO.colorData = Bitmap(loader.content).bitmapData;
			loadBitmapData(sourceThumbnailURL, onSourceThumbComplete, onLoadError);
		}

		private function onSourceThumbComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			_paintingGalleryVO.sourceThumbnail = Bitmap(loader.content).bitmapData;

			loadNormalSpecular();
		}

		private function loadNormalSpecular() : void
		{
			var loader : URLLoader = new URLLoader();
			_activeLoader = loader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onNormalSpecularComplete, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
			loader.load(new URLRequest(normalSpecularMapURL));
		}

		private function onNormalSpecularComplete(event : Event) : void
		{
			var loader : URLLoader = URLLoader(event.target);
			_paintingGalleryVO.normalSpecularData = loader.data;
			_paintingGalleryVO.normalSpecularData.uncompress();

			_onComplete(_paintingGalleryVO);
		}
	}
}
