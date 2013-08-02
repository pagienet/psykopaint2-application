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

			trace( this, "connecting shake and bake assets - 1/3 loading swf..." );

			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener( Event.COMPLETE, onAssetsLoaded );
			_urlLoader.load( new URLRequest( swfUrl ) );
		}

		private function onAssetsLoaded( event:Event ):void {

			trace( this, "connecting shake and bake assets - 2/3 mounting bytes... " );

			_urlLoader.removeEventListener( Event.COMPLETE, onAssetsLoaded );

			var loader:Loader = new Loader();
			var assetsBytes:ByteArray = _urlLoader.data;
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			context.allowCodeImport = true;
			loader.contentLoaderInfo.addEventListener( Event.INIT, onBytesLoaded );
			loader.loadBytes( assetsBytes, context );
		}

		private function onBytesLoaded( event:Event ):void {

			trace( this, "connecting shake and bake assets - 3/3 waiting 1 frame... " );

			addEventListener( Event.ENTER_FRAME, firstFrameHandler );

		}

		private function firstFrameHandler( event:Event ):void {

			trace( this, "connecting shake and bake assets - done " );

			removeEventListener( Event.ENTER_FRAME, firstFrameHandler );
			_urlLoader = null;

			// TODO: waiting for 1 frame doesn't seem to do the trick on all cases, using a time out for now
			setTimeout( function():void {
				connectedSignal.dispatch();
			}, 1000 );
		}
	}
}
