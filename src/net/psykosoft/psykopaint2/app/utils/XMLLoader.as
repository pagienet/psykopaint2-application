package net.psykosoft.psykopaint2.app.utils
{

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XMLLoader
	{
		private var _loader:URLLoader;
		private var _callback:Function;

		public function XMLLoader() {
			super();
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, onLoaderComplete );
		}

		public function loadAsset( url:String, callback:Function ):void {
			_callback = callback;
			_loader.load( new URLRequest( url ) );
		}

		public function dispose():void {
			_callback = null;
			_loader.removeEventListener( Event.COMPLETE, onLoaderComplete );
			_loader = null;
		}

		private function onLoaderComplete( event:Event ):void {
			var xml:XML = new XML( event.target.data );
			_callback( xml );
		}
	}
}
