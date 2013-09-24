package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	import net.psykosoft.psykopaint2.core.data.RetrievePaintingsDataProcessModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoFileReadSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingInfoFileReadSignal;

	public class RetrieveAllSavedPaintingInfosCommand extends AsyncCommand
	{
		[Inject]
		public var vo:RetrievePaintingsDataProcessModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var notifyPaintingInfoFileReadSignal:NotifyPaintingInfoFileReadSignal;

		[Inject]
		public var requestPaintingInfoFileReadSignal:RequestPaintingInfoFileReadSignal;

		override public function execute():void {

			trace( this, "execute()" );

			vo.paintingVos = new Vector.<PaintingInfoVO>();

			if( vo.numPaintingFiles > 0 ) {
				trace( this, "starting to read painting files... ( " + vo.numPaintingFiles + " )" );
				readNextFile();
			}
			else exitCommand();
		}

		private function readNextFile():void {
			var fileName:String = vo.paintingFileNames[ vo.paintingInfoBeingReadIndex ];
			notifyPaintingInfoFileReadSignal.addOnce( onFileRead );
			requestPaintingInfoFileReadSignal.dispatch( fileName );
		}

		private function onFileRead( info:PaintingInfoVO ):void {
			if( info ) vo.paintingVos.push( info );
			vo.paintingInfoBeingReadIndex++;
			if( vo.paintingInfoBeingReadIndex < vo.numPaintingFiles ) {
				readNextFile();
			}
			else exitCommand();
		}

		private function exitCommand():void {
			paintingModel.setPaintingCollection( vo.paintingVos );
			dispatchComplete( true );
		}
	}
}
