package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.drawing.actions.CanvasSnapShot;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;

	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class ClearCanvasCommand
	{
		[Inject]
		public var history : CanvasHistoryModel;

		[Inject]
		public var paintModule : PaintModule;

		[Inject]
		public var canvas : CanvasModel;

		public function execute():void
		{
			paintModule.stopAnimations();
			history.takeSnapshot();
			canvas.clearColorTexture();
			canvas.clearNormalSpecularTexture();
		}
	}
}
