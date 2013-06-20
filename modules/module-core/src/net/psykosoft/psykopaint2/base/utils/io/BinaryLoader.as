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
		private var _callback:Function;
		private var _url:String;

		public function BinaryLoader() {
			super();
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
		}

		public function loadAsset( url:String, callback:Function ):void {
			trace( this, "loading asset: " + url );
			_url = url;
			_callback = callback;
			_loader.load( new URLRequest( url ) );
			_url = url;
		}

		public function dispose():void {
			// TODO: if disposed, make sure all potential previous loading is stopped
			_callback = null;
			_loader.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
			_loader = null;
			_url = null;
		}

		private function onLoaderComplete( event:Event ):void {
			trace( this, "loaded: " + _url );
			_callback( _loader.data );
		}

		private function onLoaderError( event:IOErrorEvent ):void {
			throw new Error( this + event +" cannot find " + _url);
//			trace( this + event +" cannot find " + _url);
		}
	}
}
