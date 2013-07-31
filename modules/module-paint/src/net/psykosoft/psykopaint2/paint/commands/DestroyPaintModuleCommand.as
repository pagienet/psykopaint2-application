package net.psykosoft.psykopaint2.paint.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;

	public class DestroyPaintModuleCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		[Inject]
		public var notifyPaintModuleDestroyedSignal : NotifyPaintModuleDestroyedSignal;

		override public function execute() : void
		{
			super.execute();
			canvasModel.disposePaintTextures();
			canvasHistoryModel.clearHistory();	// cleans up snapshot memory too
			canvasRenderer.disposeBackground();

			notifyPaintModuleDestroyedSignal.dispatch();
		}
	}
}
