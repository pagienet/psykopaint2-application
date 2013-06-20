package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XMLLoader
	{
		private var _loader:URLLoader;
		private var _callback:Function;
		private var _url:String;

		public function XMLLoader() {
			super();
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
		}

		public function loadAsset( url:String, callback:Function ):void {
			trace( this, "loading asset: " + url );
			_url = url;
			_callback = callback;
			_loader.load( new URLRequest( url ) );
		}

		public function dispose():void {
			_callback = null;
			_loader.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader = null;
		}

		private function onLoaderComplete( event:Event ):void {
			trace( this, "loaded: " + _url );
			var xml:XML = new XML( event.target.data );
			_callback( xml );
		}

		private function onLoaderError( event:IOErrorEvent ):void {
			throw new Error( this + event );
		}
	}
}
