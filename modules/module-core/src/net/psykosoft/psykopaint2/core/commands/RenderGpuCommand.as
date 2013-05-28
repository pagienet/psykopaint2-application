package net.psykosoft.psykopaint2.core.commands
{

	import flash.display.Stage3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RenderGpuCommand extends Command
	{
		public static var renderTime:Number = 0;

		[Inject]
		public var stage3D:Stage3D;

		override public function execute():void {
			super.execute();

			// TODO: bring in render time

			var preTime:Number = getTimer();

			var i:uint;
			var len:uint;
			var steps:Vector.<Function>;

			// Pre-clear steps.
			steps = GpuRenderManager.preRenderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			// Clear.
			stage3D.context3D.setRenderToBackBuffer();
			stage3D.context3D.clear( 1, 1, 1, 1 );

			// Normal steps.
			steps = GpuRenderManager.renderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			// Present.
			stage3D.context3D.present();

			// Post-present steps.
			steps = GpuRenderManager.postRenderingSteps;
			len = steps.length;
			for( i = 0; i < len; ++i ) steps[ i ]();

			renderTime = getTimer() - preTime;
		}
	}
}
