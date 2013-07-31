package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetCanvasSurfaceSignal;

	import robotlegs.bender.framework.api.IContext;

	public class LoadSurfaceCommand extends TracingCommand
	{
		[Inject]
		public var index:uint; // From signal.

		[Inject]
		public var requestDrawingCoreSurfaceSetSignal:RequestSetCanvasSurfaceSignal;

		[Inject]
		public var context:IContext;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		private var _byteLoader:BinaryLoader;
		private var _bitmapLoader:BitmapLoader;
		private var _loadedNormalSpecularData:ByteArray;
		private var _loadedColorData:BitmapData;
		private var _assetSize:String;

		public function LoadSurfaceCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			context.detain( this );

			_assetSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048" : "1024";
			loadColorData();
		}

		private function loadColorData():void {
			_bitmapLoader = new BitmapLoader();
			_bitmapLoader.loadAsset( "/core-packaged/images/surfaces/canvas_color_" + index + "_" + _assetSize + ".jpg",
					onColorDataLoaded,
					onColorDataError );
		}

		private function onColorDataError():void {
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			trace( "Error loading '/core-packaged/images/surfaces/canvas_color_" + index + "_" + _assetSize + ".surf'" );
			loadNormalSpecularData();
		}

		private function onColorDataLoaded( bitmap:BitmapData ):void {
			_loadedColorData = bitmap;
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData():void {
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + _assetSize + ".surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			_loadedNormalSpecularData = bytes;
			_byteLoader.dispose();
			_byteLoader = null;

			requestDrawingCoreSurfaceSetSignal.dispatch( _loadedNormalSpecularData, _loadedColorData );
			notifySurfaceLoadedSignal.dispatch();
			context.release( this );
		}
	}
}
