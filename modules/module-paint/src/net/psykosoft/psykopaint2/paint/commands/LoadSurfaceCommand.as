package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.models.CanvasSurfaceSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	
	import robotlegs.bender.framework.api.IContext;

	// TODO: Identifying surfaces using indices is error prone, should be actual ids into a (xml) database rather than some hardcoded array
	// TODO: Move this out of paint module
	public class LoadSurfaceCommand extends TracingCommand
	{
		[Inject]
		public var paintMode : int;	// PaintMode.PHOTO_MODE or PaintMode.COLOR_MODE, coming from signal

		[Inject]
		public var canvasSurfaceSettingsModel : CanvasSurfaceSettingsModel;

		[Inject]
		public var context:IContext;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		private var _assetSize:String;
		private var _loader:Loader;

		private var _surfaceData:SurfaceDataVO;

		public function LoadSurfaceCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			ConsoleView.instance.log( this, "execute()" );

			context.detain( this );

			_surfaceData = new SurfaceDataVO();
			_assetSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? "2048" : "1024";

			if (paintMode == PaintMode.COLOR_MODE)
				loadColorAndNormalData();
			else
				loadNormalSpecular();
		}

		private function loadColorAndNormalData():void
		{
			loadImage("/core-packaged/images/surfaces/canvas_color_" + canvasSurfaceSettingsModel.surfaceID + "_" + _assetSize + ".jpg", onColorLoaded, onColorError);
		}

		private function onColorLoaded(event : Event) : void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onColorLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onColorError);

			var bitmapData : BitmapData = Bitmap(_loader.content).bitmapData;
			_surfaceData.color = bitmapData.getPixels(bitmapData.rect);
			ImageDataUtils.ARGBtoBGRA(_surfaceData.color, bitmapData.width * bitmapData.height * 4, 0);
			bitmapData.dispose();

			loadNormalSpecular();
		}

		private function onColorError(event:IOErrorEvent):void
		{
			loadNormalSpecular();
		}

		private function loadNormalSpecular():void
		{
			loadImage("/core-packaged/images/surfaces/canvas_normal_specular_" + canvasSurfaceSettingsModel.surfaceID + "_" + _assetSize + ".png", onSurfaceLoaded);
		}

		private function onSurfaceLoaded(event : Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSurfaceLoaded);

			_surfaceData.normalSpecular = Bitmap(_loader.content).bitmapData;
			_loader = null;

			notifySurfaceLoadedSignal.dispatch(_surfaceData);
			context.release( this );
		}

		private function loadImage(filename:String, onComplete:Function, onError:Function = null):void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			if (onError) _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.load(new URLRequest(filename));
		}
	}
}
