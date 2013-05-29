package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;

	public class RedoCanvasActionCommand
	{
		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		public function execute() : void
		{
			canvasHistory.redo();
		}
	}
}
