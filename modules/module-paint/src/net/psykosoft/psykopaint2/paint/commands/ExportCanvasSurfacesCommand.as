package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.io.CanvasExportEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasExporter;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	public class ExportCanvasSurfacesCommand extends AsyncCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var saveVO:SavePaintingVO;

		override public function execute():void {

			trace( this + ", execute()" );

			var canvasExporter:CanvasExporter = new CanvasExporter();
			canvasExporter.addEventListener( CanvasExportEvent.COMPLETE, onExportComplete );
			canvasExporter.export( canvasModel );
		}

		private function onExportComplete( event:CanvasExportEvent ):void {
			event.target.removeEventListener( CanvasExportEvent.COMPLETE, onExportComplete );
			saveVO.data = event.paintingDataVO;
			dispatchComplete( true );
		}
	}
}
