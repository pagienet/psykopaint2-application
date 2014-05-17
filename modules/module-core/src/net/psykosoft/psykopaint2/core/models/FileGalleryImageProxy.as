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
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class FileGalleryImageProxy extends GalleryImageProxy
	{
		// public for convenience, not accessible through views as interface anyway
		public var normalSpecularMapURL  : String;
		public var colorMapURL  : String;
		public var sourceThumbnailURL : String;
		
		public var tinySizeURL : String;
		public var smallSizeURL : String;
		public var mediumSizeURL:String;
		public var fullsizeURL : String;

		private var _onColorComplete : Function;
		private var _onComplete : Function;
		private var _onError : Function;
		private var _paintingGalleryVO : PaintingGalleryVO;
		private static var _scaleDownMatrix : Matrix = new Matrix(.5, 0, 0, .5);

		private var _activeLoader : Object;
		private var _sizeHint:int=1;

		public function FileGalleryImageProxy()
		{
		}

		override public function cancelLoading() : void
		{
			_onComplete = null;
			_onError = null;
			try {
				if (_activeLoader){
					_activeLoader.close();
				}
			}
			catch(error : Error) {

			}

			if (_paintingGalleryVO) {
				_paintingGalleryVO.dispose();
				_paintingGalleryVO = null;
			}

			_activeLoader = null;
		}

		override public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			if (_onComplete) cancelLoading();
			
			_sizeHint = size;
			_onComplete = onComplete;
			_onError = onError;
			var urlToLoad:String = "";
			if(size==ImageThumbnailSize.TINY){
				urlToLoad= tinySizeURL;
				
			}else if(size==ImageThumbnailSize.SMALL){
				urlToLoad= smallSizeURL;
				
			}else if(size==ImageThumbnailSize.MEDIUM){
				urlToLoad= mediumSizeURL;
			} 
			else if(size==ImageThumbnailSize.FULLSIZE){
				urlToLoad= fullsizeURL;
			} 
			
			loadBitmapData(urlToLoad, onThumbLoadComplete, onLoadError);
		}
		
		

		override public function loadFullSizedComposite(onComplete : Function, onError : Function) : void
		{
			if (_onComplete) cancelLoading();
			_onComplete = onComplete;
			_onError = onError;
			
			//IF ALREADY LOADED WE JUST CALL THE onCOMPLETE FUNCTION:
			if(_paintingGalleryVO && _paintingGalleryVO.compositedFullSize){
				callOnComplete(_paintingGalleryVO.compositedFullSize);
			}else {
				loadBitmapData(fullsizeURL, onCompositeLoadComplete, onLoadError);
			}
		}

		private function loadBitmapData(filename : String, onComplete : Function, onError : Function) : void
		{
			var loader : Loader = new Loader();
			_activeLoader = loader;
			//Asynchronous decoding
			var loaderContext:LoaderContext = new LoaderContext(); 
			loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD ;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(new URLRequest(filename),loaderContext);
		}

		private function onThumbLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);

			var bitmapData : BitmapData = Bitmap(loader.content).bitmapData;
			//MATHIEU: WHAT'S THE IDEA BEHIND THIS?
			if (_sizeHint == ImageThumbnailSize.SMALL) {
				var source : BitmapData = bitmapData;
				bitmapData = new TrackedBitmapData(source.width *.5, source.height *.5, false);
				bitmapData.drawWithQuality(source, _scaleDownMatrix, null, null, null, true, StageQuality.BEST);
				
				source.dispose();
			}

			callOnComplete(bitmapData);
		}

		private function onCompositeLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			
			if (_paintingGalleryVO) {
				_paintingGalleryVO.compositedFullSize = Bitmap(loader.content).bitmapData;}
			
			callOnComplete(Bitmap(loader.content).bitmapData);
		}

		private function callOnComplete(data : Object) : void
		{
			// need to nullify before callback because loading needs to be possible again inside the callback
			var onComplete : Function = _onComplete;
			_onComplete = null;
			_onError = null;
			_activeLoader = null;
			if (onComplete) onComplete(data);
		}

		private function onLoadError(event : IOErrorEvent) : void
		{
			// need to nullify before callback because loading needs to be possible again
			var onError : Function = _onError;
			_onComplete = null;
			_onError = null;
			_activeLoader = null;

			trace ("Error loading image: " + event.text);

			if (_paintingGalleryVO) _paintingGalleryVO.dispose();
			_paintingGalleryVO = null;

			onError();
		}

		override public function loadSurfaceData(onComplete:Function, onError:Function, onSurfaceColorDataComplete:Function = null) :void
		{
			if (_onComplete) cancelLoading();
			if (_paintingGalleryVO) onComplete(_paintingGalleryVO);
			_onColorComplete = onSurfaceColorDataComplete;

			_paintingGalleryVO = new PaintingGalleryVO();
			_onComplete = onComplete;
			_onError = onError;
			loadBitmapData(colorMapURL, onColorMapComplete, onLoadError);
		}

		private function onColorMapComplete(event : Event) : void
		{
			try {
				_activeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onColorMapComplete);
			
				_activeLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				var bitmapData : BitmapData = Bitmap(_activeLoader.content).bitmapData;
	
				// sometimes, a freak occurrence causes the callback to be reached after cancelling
				if (_paintingGalleryVO) {
					_paintingGalleryVO.colorData = bitmapData;
	
					if (_onColorComplete)
						_onColorComplete(_paintingGalleryVO);
	
					loadBitmapData(normalSpecularMapURL, onNormalSpecularComplete, onLoadError);
				}
				else {
					// may have been disposed()
					bitmapData.dispose();
				}
			}catch (e:Error){
				trace("ERROR IN THERE that happens once in a while when moving too fast or something. Might want to check later.I Put that now so it doesn't break at least:\n"+e);
			}
		}

		private function onNormalSpecularComplete(event : Event) : void
		{
			_activeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onColorMapComplete);
			_activeLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			if (_paintingGalleryVO) {
				_paintingGalleryVO.normalSpecularData = Bitmap(_activeLoader.content).bitmapData;
				_activeLoader = null;
				callOnComplete(_paintingGalleryVO);
				_paintingGalleryVO = null;
			}
			else {
				Bitmap(_activeLoader.content).bitmapData.dispose();
			}
		}

		override public function clone():GalleryImageProxy
		{
			var clone : FileGalleryImageProxy = new FileGalleryImageProxy();
			copyTo(clone);
			clone.normalSpecularMapURL = normalSpecularMapURL;
			clone.colorMapURL = colorMapURL;
			clone.sourceThumbnailURL = sourceThumbnailURL;
			clone.smallSizeURL = smallSizeURL;
			clone.tinySizeURL = tinySizeURL;
			clone.mediumSizeURL = mediumSizeURL;
			clone.fullsizeURL = fullsizeURL;
			return clone;
		}
	}
}
