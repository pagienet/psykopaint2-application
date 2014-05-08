package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
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

		private var _assetSize:String;
		private var _loader:Loader;

		public function LoadSurfaceCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			ConsoleView.instance.log( this, "execute()" );

			context.detain( this );

			_assetSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048" : "1024";
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData():void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSurfaceLoaded);
			_loader.load( new URLRequest("/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + _assetSize + ".png" ));
		}

		private function onSurfaceLoaded(event : Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSurfaceLoaded);

			var surfaceData : SurfaceDataVO = new SurfaceDataVO();
			surfaceData.normalSpecular = Bitmap(_loader.content).bitmapData;
			_loader = null;

			notifySurfaceLoadedSignal.dispatch(surfaceData);
			context.release( this );
		}
	}
}
