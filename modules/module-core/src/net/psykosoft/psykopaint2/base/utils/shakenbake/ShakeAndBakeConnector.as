package net.psykosoft.psykopaint2.base.utils.shakenbake
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import org.osflash.signals.Signal;

	public class ShakeAndBakeConnector extends Sprite
	{
		private var _urlLoader:URLLoader;

		public var connectedSignal:Signal;

		public function ShakeAndBakeConnector() {
			super();
			connectedSignal = new Signal();
		}

		public function connectAssetsAsync( swfUrl:String ):void {
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener( Event.COMPLETE, onAssetsLoaded );
			_urlLoader.load( new URLRequest( swfUrl ) );
		}

		private function onAssetsLoaded( event:Event ):void {

			_urlLoader.removeEventListener( Event.COMPLETE, onAssetsLoaded );

			addEventListener( Event.ENTER_FRAME, firstFrameHandler );

			var loader:Loader = new Loader();
			var assetsBytes:ByteArray = _urlLoader.data;
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			context.allowCodeImport = true;
			loader.loadBytes( assetsBytes, context );
		}

		private function firstFrameHandler( event:Event ):void {

			removeEventListener( Event.ENTER_FRAME, firstFrameHandler );
			_urlLoader = null;

			// TODO: waiting for 1 frame doesn't seem to do the trick on all cases, using a time out for now
			setTimeout( function():void {
				connectedSignal.dispatch();
			}, 1000 );
		}
	}
}
