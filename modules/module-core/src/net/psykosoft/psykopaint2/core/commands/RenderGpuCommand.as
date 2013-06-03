package net.psykosoft.psykopaint2.core.commands
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import flash.display3D.Context3D;
	import flash.geom.Matrix;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;

	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyCanvasSnapshotSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RenderGpuCommand extends Command
	{
		public static var renderTime:Number = 0;
		public static var snapshotRequested:Boolean;

		[Inject]
		public var stage3DProxy:Stage3DProxy;

		[Inject]
		public var notifyCanvasBitmapSignal:NotifyCanvasSnapshotSignal;

		override public function execute():void {
			super.execute();

			var context:Context3D = stage3DProxy.context3D;
			if( !context ) return;

			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "gpu render ------------------------" );
			}

			var preTime:Number = getTimer();

			var i:uint;
			var len:uint;
			var steps:Vector.<Function>;

			// Pre-clear steps.
			steps = GpuRenderManager.preRenderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			// Clear.
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "clear context" );
			}
			stage3DProxy.context3D.setRenderToBackBuffer();
			stage3DProxy.context3D.clear( 1, 1, 1, 1 );

			// Normal steps.
			steps = GpuRenderManager.renderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			if( snapshotRequested ) {
				trace( this, "taking snapshot ------------------------------"  );
				var bmd:BitmapData = new BitmapData( ViewCore.globalScaling * stage3DProxy.width, ViewCore.globalScaling * stage3DProxy.height, true, 0 );
				stage3DProxy.context3D.drawToBitmapData( bmd );
				if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
					var matrix:Matrix = new Matrix();
					matrix.scale( 0.5, 0.5 );
					var scaledDownBmd:BitmapData = new BitmapData( stage3DProxy.width, stage3DProxy.height, false, 0 );
					scaledDownBmd.draw( bmd, matrix );
					bmd = scaledDownBmd;
				}
				notifyCanvasBitmapSignal.dispatch( bmd );
				snapshotRequested = false;
			}

			// Present.
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "present proxy" );
			}
			stage3DProxy.present();

			// Post-present steps.
			steps = GpuRenderManager.postRenderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			renderTime = getTimer() - preTime;
		}
	}
}
