package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class BinaryLoader
	{
		private var _loader:URLLoader;
		private var _successCallback:Function;
		private var _errorCallback : Function;
		private var _url:String;

		public function BinaryLoader() {
			super();
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
		}

		public function loadAsset( url:String, successCallback:Function, errorCallback:Function = null ):void {
			trace( this, "loading asset: " + url );
			_url = url;
			_successCallback = successCallback;
			_errorCallback = errorCallback;
			_loader.load( new URLRequest( url ) );
			_url = url;
		}

		public function dispose():void {
			if (_loader) _loader.close();
			_successCallback = null;
			_errorCallback = null;
			_loader.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
			_loader = null;
			_url = null;
		}

		private function onLoaderComplete( event:Event ):void {
			trace( this, "loaded: " + _url );
			_successCallback( _loader.data );
		}

		private function onLoaderError( event:IOErrorEvent ):void {
			if (_errorCallback)
				_errorCallback();
			else
				throw new Error( this + event +" cannot find " + _url);
//			trace( this + event +" cannot find " + _url);
		}
	}
}
