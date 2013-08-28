package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.display.Stage;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.io.CanvasExportEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasExporter;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	public class ExportCanvasSurfacesCommand extends AsyncCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var saveVO:SavePaintingVO;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var ioAne:IOAneManager;

		private var _time:uint;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );
			_time = getTimer();

			var canvasExporter:CanvasExporter = new CanvasExporter( stage, ioAne );
			canvasExporter.addEventListener( CanvasExportEvent.COMPLETE, onExportComplete );
			canvasExporter.export( canvasModel );
		}

		private function onExportComplete( event:CanvasExportEvent ):void {
			event.target.removeEventListener( CanvasExportEvent.COMPLETE, onExportComplete );
			saveVO.data = event.paintingDataVO;
			dispatchComplete( true );
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
