package net.psykosoft.psykopaint2.paint.commands.saving
{
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class DisposeCanvasNonEssentialsCommand extends AsyncCommand
	{
		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var historyModel : CanvasHistoryModel;

		override public function execute() : void
		{
			canvasModel.disposeBackBuffer();
			historyModel.clearHistory();
			dispatchComplete(true);
		}
	}
}
