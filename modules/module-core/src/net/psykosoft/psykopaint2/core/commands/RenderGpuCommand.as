package net.psykosoft.psykopaint2.core.commands
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RenderGpuCommand extends Command
	{
		public static var renderTime:Number = 0;

		[Inject]
		public var stage3DProxy:Stage3DProxy;

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

			// Clear proxy.
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "clear proxy" );
			}
			stage3DProxy.clear();

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
