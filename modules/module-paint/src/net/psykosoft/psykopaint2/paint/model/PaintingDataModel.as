package net.psykosoft.psykopaint2.paint.model
{

	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;

	public class PaintingDataModel
	{
		[Inject]
		public var notifyPaintingDataRetrievedSignal:NotifyPaintingDataRetrievedSignal;

		private var _paintingData:Vector.<PaintingVO>;

		public function PaintingDataModel() {
			super();
		}

		public function setPaintingData( data:Vector.<PaintingVO> ):void {
			trace( this, "setting painting data: " + data );
			_paintingData = data;
			notifyPaintingDataRetrievedSignal.dispatch( _paintingData );
		}
	}
}
