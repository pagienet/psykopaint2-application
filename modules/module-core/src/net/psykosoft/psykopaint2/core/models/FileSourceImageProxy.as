package net.psykosoft.psykopaint2.core.models
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class FileSourceImageProxy implements SourceImageProxy
	{
		// public for convenience, not accessible through interface anyway
		public var id : int;
		public var lowResThumbnailFilename : String;
		public var highResThumbnailFilename : String;
		public var originalFilename : String;
		//book debug
		public var debugFilename : String;
		
		private var _activeLoader:Object;
		
		private var _onComplete : Function;
		private var _onError : Function;

	  public function cancelLoading() : void
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
			
			_activeLoader = null;
		}
		
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
			cancelLoading();

			_onComplete = onComplete;
			_onError = onError;
			
			trace("FileSourceImageProxy::LOAD FILE "+filename);
			if (filename.indexOf(".atf")!=-1){
				var urlloader : URLLoader = new URLLoader();
				urlloader.addEventListener(Event.COMPLETE, onLoadATFComplete);
				urlloader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				urlloader.dataFormat= URLLoaderDataFormat.BINARY;
				_activeLoader = urlloader;
				urlloader.load(new URLRequest(filename));
			}else {
				
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_activeLoader = loader;
				loader.load(new URLRequest(filename));
			}
			
			//book debug
			debugFilename = filename;
		}
		
	
		
		protected function onLoadATFComplete(event:Event):void
		{
			var urlLoader:URLLoader = URLLoader(event.target);
			
			urlLoader.removeEventListener(Event.COMPLETE, onLoadComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			var onComplete : Function = _onComplete;
			_onComplete = null;
			_onError = null;
			
			
			onComplete((urlLoader.data));
			
			
		}		
		
		
		private function onLoadComplete(event : Event) : void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			event.target.removeEventListener(Event.COMPLETE, onLoadComplete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			// need to nullify before callback because loading needs to be possible again
			var onComplete : Function = _onComplete;
			_onComplete = null;
			_onError = null;
			
			if(onComplete) onComplete(Bitmap(loader.content).bitmapData);
			
		}

		private function onLoadError(event : IOErrorEvent) : void
		{
			
			event.target.removeEventListener(Event.COMPLETE, onLoadComplete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			// need to nullify before callback because loading needs to be possible again
			var onError : Function = _onError;
			_onComplete = null;
			_onError = null;
			onError();
		}

	}
}
