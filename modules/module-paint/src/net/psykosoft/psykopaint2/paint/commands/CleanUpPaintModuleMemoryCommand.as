package net.psykosoft.psykopaint2.paint.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class CleanUpPaintModuleMemoryCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		override public function execute() : void
		{
			super.execute();
			canvasModel.disposePaintTextures();
			canvasHistoryModel.clearHistory();	// cleans up snapshot memory too
			canvasRenderer.disposeBackground();
		}
	}
}
