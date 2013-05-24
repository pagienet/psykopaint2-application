package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.paint.signals.requests.RequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

//	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class StartUpDrawingCoreCommand extends TracingCommand
	{
		[Embed(source="/../assets/embedded/images/diffuseTestProbe.jpg")]
		private var EnvMapAsset:Class;

		[Embed(source="/../assets/embedded/images/canvas-height-specular.png")]
		private var DefaultHeightSpecularMap:Class;

		[Embed(source="/../assets/embedded/images/aa.jpg")]
		private var DefaultImage:Class;

		[Inject]
		public var canvasModel:CanvasModel;

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

		override public function execute():void {

			super.execute();

			canvasModel.setHeightSpecularMap( new DefaultHeightSpecularMap().bitmapData );
			lightController.enabled = true;

//			initEnvMap();

			// Initial auto-setup:
			// We assume that confirming a color style activates the core's paint module.
			// TODO: remove time out
			var bitmapData:BitmapData = new DefaultImage().bitmapData;
//			requestSourceImageSetSignal.dispatch( bitmapData );
			setTimeout( function():void {
				// Pick one below...
//				requestStateChangeSignal.dispatch( StateType.STATE_PICK_IMAGE ); // Launches app in pick an image ( default image ignored ).
//				requestSourceImageSetSignal.dispatch( bitmapData ); // Launches app in crop mode.
//				notifyCropCompleteSignal.dispatch( bitmapData ); // Launches app in color style mode.
				notifyColorStyleCompleteSignal.dispatch( bitmapData ); // Launches app in paint mode.
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
