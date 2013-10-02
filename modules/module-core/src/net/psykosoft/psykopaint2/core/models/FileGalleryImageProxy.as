package net.psykosoft.psykopaint2.core.models
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class FileGalleryImageProxy extends GalleryImageProxy
	{
		// public for convenience, not accessible through views as interface anyway
		public var fullsizeFilename : String;
		public var highResThumbnailFilename : String;
		public var lowResThumbnailFilename : String;

		private var _onComplete : Function;
		private var _onError : Function;


		public function FileGalleryImageProxy()
		{
		}

		override public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			load(onComplete, onError, size == ImageThumbnailSize.LARGE ? highResThumbnailFilename : lowResThumbnailFilename);
		}

		override public function loadFullsized(onComplete : Function, onError : Function) : void
		{
			load(onComplete, onError, fullsizeFilename);
		}

		private function load(onComplete : Function, onError : Function, filename : String) : void
		{
			if (_onComplete != null) throw "Already loading!";

			_onComplete = onComplete;
			_onError = onError;

			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(new URLRequest(filename));
		}

		private function onLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			removeListeners(loader);

			// need to nullify before callback because loading needs to be possible again
			var onComplete : Function = _onComplete;
			_onComplete = null;
			_onError = null;
			onComplete(Bitmap(loader.content).bitmapData);
		}

		private function onLoadError(event : IOErrorEvent) : void
		{
			removeListeners(LoaderInfo(event.target));

			// need to nullify before callback because loading needs to be possible again
			var onError : Function = _onError;
			_onComplete = null;
			_onError = null;
			onError();
		}

		private function removeListeners(loader : LoaderInfo) : void
		{
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}
	}
}
