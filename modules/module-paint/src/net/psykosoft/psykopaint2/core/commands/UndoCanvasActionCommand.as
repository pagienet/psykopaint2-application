package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;

	public class UndoCanvasActionCommand
	{
		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		[Inject]
		public var paintModule : BrushKitManager;

		public function execute() : void
		{
			paintModule.stopAnimations();
			canvasHistory.undo();
		}
	}
}
