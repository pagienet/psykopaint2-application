package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;

	public class StartUpDrawingCoreCommand extends TracingCommand
	{
		[Inject]
		public var lightController:GyroscopeLightController;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		override public function execute():void {

			super.execute();

			lightController.enabled = true;

			requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );

			// TODO: remove this - this is a hack to activate the paint module
			// This should be removed and module concatenation in ModuleManager.as should be removed
			var perlinBmd:BitmapData = new BitmapData( 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING, false, 0 );
			perlinBmd.perlinNoise( 50, 50, 8, uint( 1000 * Math.random() ), false, true, 7, true );
			notifyColorStyleCompleteSignal.dispatch( perlinBmd );
		}
	}
}
