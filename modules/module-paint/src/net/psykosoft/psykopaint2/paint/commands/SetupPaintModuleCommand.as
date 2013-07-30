package net.psykosoft.psykopaint2.paint.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class SetupPaintModuleCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		override public function execute() : void
		{
			super.execute();

			canvasModel.createPaintTextures();
			canvasHistoryModel.clearHistory();
		}
	}
}
