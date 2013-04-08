package net.psykosoft.psykopaint2.app.utils.loaders
{

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BitmapLoader
	{
		private var _loader:Loader;
		private var _callback:Function;

		public function BitmapLoader() {
			super();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderComplete );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
		}

		public function loadAsset( url:String, callback:Function ):void {
			trace( this, "loading asset: " + url );
			_callback = callback;
			_loader.load( new URLRequest( url ) );
		}

		public function dispose():void {
			_callback = null;
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader = null;
		}

		private function onLoaderComplete( event:Event ):void {
			trace( this, "loaded." );
			var bmd:BitmapData = new BitmapData( _loader.width, _loader.height, false, 0 );
			bmd.draw( _loader );
			_callback( bmd );
		}

		private function onLoaderError( event:IOErrorEvent ):void {
			throw new Error( this + event );
		}
	}
}
