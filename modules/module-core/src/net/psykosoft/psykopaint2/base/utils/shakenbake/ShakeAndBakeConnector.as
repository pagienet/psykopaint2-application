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

	import org.osflash.signals.Signal;

	public class ShakeAndBakeConnector extends Sprite
	{
		private var _urlLoader:URLLoader;
		private var _loader:Loader;
		private var _frameDelayCount:int;

		public var connectedSignal:Signal;

		public function ShakeAndBakeConnector() {
			super();
			connectedSignal = new Signal();
		}

		public function connectAssetsAsync( swfUrl:String ):void {

			trace( this, "connecting shake and bake assets - 1/3 loading swf..." );

			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener( Event.COMPLETE, onAssetsLoaded );
			_urlLoader.load( new URLRequest( swfUrl ) );
		}

		private function onAssetsLoaded( event:Event ):void {

			trace( this, "connecting shake and bake assets - 2/3 mounting bytes... " );

			_urlLoader.removeEventListener( Event.COMPLETE, onAssetsLoaded );

			_loader = new Loader();
			var assetsBytes:ByteArray = _urlLoader.data;
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			context.allowCodeImport = true;
			_loader.contentLoaderInfo.addEventListener( Event.INIT, onBytesLoaded );
			_loader.loadBytes( assetsBytes, context );
		}

		private function onBytesLoaded( event:Event ):void {

			_loader.contentLoaderInfo.removeEventListener( Event.INIT, onBytesLoaded );

			_urlLoader.data.length = 0;
			_urlLoader.data = null;
			_urlLoader = null;

			trace( this, "connecting shake and bake assets - 3/3 waiting a few frames... " );
			_frameDelayCount = 0;
			addEventListener( Event.ENTER_FRAME, firstFrameHandler );
		}

		private function firstFrameHandler( event:Event ):void {
			_frameDelayCount++;
			if ( _frameDelayCount == 1 )
			{
				_urlLoader = null;
			} else if ( _frameDelayCount == 3 ) 
			{
				trace( this, "connecting shake and bake assets - done " );
				removeEventListener( Event.ENTER_FRAME, firstFrameHandler );
				connectedSignal.dispatch();
			}
		}

		public function cleanUp():void {
			_loader.unloadAndStop( true );
			_loader = null;
			connectedSignal = null;
		}
	}
}
