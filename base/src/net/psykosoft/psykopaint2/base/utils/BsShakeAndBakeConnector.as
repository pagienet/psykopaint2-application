package net.psykosoft.psykopaint2.base.utils
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

	public class BsShakeAndBakeConnector extends Sprite
	{
		private var _container:Sprite;
		private var _urlLoader:URLLoader;

		public var connectedSignal:Signal;

		public function BsShakeAndBakeConnector() {
			super();
			connectedSignal = new Signal();
		}

		public function connectAssetsAsync( container:Sprite, swfUrl:String ):void {
			_container = container;
			container.addChild( this );
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener( Event.COMPLETE, onAssetsLoaded );
			_urlLoader.load( new URLRequest( swfUrl ) );
		}

		private function onAssetsLoaded( event:Event ):void {
			_urlLoader.removeEventListener( Event.COMPLETE, onAssetsLoaded );
			var loader:Loader = new Loader();
			var assetsBytes:ByteArray = _urlLoader.data;
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			context.allowCodeImport = true;
			loader.loadBytes( assetsBytes, context );
			addEventListener( Event.ENTER_FRAME, firstFrameHandler );
		}

		private function firstFrameHandler( event:Event ):void {
			removeEventListener( Event.ENTER_FRAME, firstFrameHandler );
			_urlLoader = null;
			_container.removeChild( this );
			_container = null;
			connectedSignal.dispatch();
		}
	}
}
