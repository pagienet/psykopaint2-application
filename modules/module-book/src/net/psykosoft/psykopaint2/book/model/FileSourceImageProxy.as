package net.psykosoft.psykopaint2.book.model
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class FileSourceImageProxy implements SourceImageProxy
	{
		// public for convenience, not accessible through interface anyway
		public var id : int;
		public var lowResThumbnailFilename : String;
		public var highResThumbnailFilename : String;
		public var originalFilename : String;

		private var _onComplete : Function;
		private var _onError : Function;

		public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			load(size == ImageThumbnailSize.LARGE? highResThumbnailFilename : lowResThumbnailFilename, onComplete, onError);
		}

		public function loadFullSized(onComplete : Function, onError : Function) : void
		{
			load(originalFilename, onComplete, onError);
		}

		private function load(filename : String, onComplete : Function, onError : Function) : void
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
