package net.psykosoft.psykopaint2.paint.commands
{

	import away3d.containers.View3D;

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class RenderFrameCommand
	{
		public static var renderTime : Number = 0;

		[Inject]
		public var moduleManager:ModuleManager;

		[Inject]
		public var lightingModel:LightingModel;

		[Inject]
		public var stage3D:Stage3D;

		[Inject]
		public var view3d:View3D;

		public function execute():void
		{
//			trace ("--------");
			var context:Context3D = stage3D.context3D;
			if( !context ) return;

			var preTime : Number = getTimer();

			lightingModel.update();

			stage3D.context3D.setRenderToBackBuffer();
			stage3D.context3D.clear(1, 1, 1, 1);

			moduleManager.render();

			if( view3d ) view3d.render();

			stage3D.context3D.present();

			renderTime = getTimer() - preTime;
		}
	}
}
