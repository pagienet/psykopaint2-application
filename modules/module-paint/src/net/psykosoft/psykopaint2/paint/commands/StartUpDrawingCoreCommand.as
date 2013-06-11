package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;

//	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class StartUpDrawingCoreCommand extends TracingCommand
	{
		[Embed(source="/../assets/embedded/images/diffuseTestProbe.jpg")]
		private var EnvMapAsset:Class;

		[Embed(source="/../assets/embedded/images/default-image.jpg")]
		private var DefaultImage:Class;

		[Inject]
		public var lightController : GyroscopeLightController;

		[Inject]
		public var stage3D:Stage3D;

		[Inject]
		public var requestSourceImageSetSignal:RequestSourceImageSetSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var stage:Stage;

		override public function execute():void {

			super.execute();

			lightController.enabled = true;

			// TODO: clean up
//			initEnvMap();

			// Initial auto-setup:
			// We assume that confirming a color style activates the core's paint module.
			// TODO: replace time out
			var bitmapData:BitmapData = new DefaultImage().bitmapData;
//			requestSourceImageSetSignal.dispatch( bitmapData );
			setTimeout( function():void {

				// Pick one below...
//				requestStateChangeSignal.dispatch( StateType.STATE_PICK_IMAGE ); // Launches app in pick an image ( default image ignored ).
//				requestSourceImageSetSignal.dispatch( bitmapData ); // Launches app in crop mode.
//				notifyCropCompleteSignal.dispatch( bitmapData ); // Launches app in color style mode.
				notifyColorStyleCompleteSignal.dispatch( bitmapData ); // Launches app in paint mode.

				// Init canvas size.
				requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );

			}, 10 );
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function initEnvMap():void {
			var bitmapData:BitmapData = new EnvMapAsset().bitmapData;
			var context3d:Context3D = stage3D.context3D;
			var environmentMap:Texture = context3d.createTexture( bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false );
			environmentMap.uploadFromBitmapData( bitmapData );
			bitmapData.dispose();
			// when changing environment map, we'll need to dispose the existing one!
			// TODO(dave): this texture is created and not used atm
		}
	}
}
