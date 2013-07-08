package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BitmapLoader
	{
		private var _loader:Loader;
		private var _successCallback:Function;
		private var _url:String;
		private var _errorCallback : Function;

		public function BitmapLoader() {
			super();
		}

		public function loadAsset( url:String, successCallback:Function, errorCallback:Function=null ):void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
			trace( this, "loading asset: " + url );
			_url = url;
			_successCallback = successCallback;
			_errorCallback = errorCallback
			_loader.load( new URLRequest( url ) );
			_url = url;
		}

		public function dispose():void {
			_successCallback = null;
			_errorCallback = null;
			if (_loader) {
				_loader.close();
				_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderComplete );
				_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
				_loader = null;
			}
			_url = null;
		}

		private function onLoaderComplete( event:Event ):void {
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderError );

			var bmd : BitmapData = Bitmap(_loader.content).bitmapData;

			_loader = null;

			_successCallback( bmd );
		}

		private function onLoaderError( event:IOErrorEvent ):void {
			if (_errorCallback)
				_errorCallback();
			else
				throw new Error( this + event +" cannot find "+_url);
		}
	}
}
