package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	
	import robotlegs.bender.framework.api.IContext;

	// TODO: Identifying surfaces using indices is error prone, should be actual ids into a (xml) database rather than some hardcoded array
	// TODO: Move this out of paint module
	public class LoadSurfaceCommand extends TracingCommand
	{
		[Inject]
		public var index:uint; // From signal.

		[Inject]
		public var context:IContext;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		private var _byteLoader:BinaryLoader;
		private var _loadedSurfaceData:SurfaceDataVO;
		private var _assetSize:String;
		private var _time:uint;

		public function LoadSurfaceCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			ConsoleView.instance.log( this, "execute()" );
			_time = getTimer();

			context.detain( this );

			_assetSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048" : "1024";
			_loadedSurfaceData = new SurfaceDataVO();
			loadColorData();
		}

		private function loadColorData():void {
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_color_" + index + "_" + _assetSize + ".surf",
					onColorDataLoaded,
					onColorDataError );
		}

		private function onColorDataError():void {
			_byteLoader.dispose();
			_byteLoader = null;
			trace( "Error loading '/core-packaged/images/surfaces/canvas_color_" + index + "_" + _assetSize + ".surf'" );
			loadNormalSpecularData();
		}

		private function onColorDataLoaded( bytes:ByteArray ):void {
			bytes.uncompress();
			_loadedSurfaceData.color = bytes;

			_byteLoader.dispose();
			_byteLoader = null;
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData():void {
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + _assetSize + ".surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			var unCompressTime:uint = getTimer();
			bytes.uncompress();
			ConsoleView.instance.log( this, "onSurfaceLoaded - un-compress time - " + String( getTimer() - unCompressTime ) );
			_loadedSurfaceData.normalSpecular = bytes;
			_byteLoader.dispose();
			_byteLoader = null;
			notifySurfaceLoadedSignal.dispatch(_loadedSurfaceData);
			context.release( this );

			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
