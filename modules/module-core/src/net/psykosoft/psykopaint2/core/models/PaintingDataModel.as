package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

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
			_paintingData = data;
			notifyPaintingDataRetrievedSignal.dispatch( _paintingData );
		}

		public function getRgbaDataForPaintingWithId( id:String ):Vector.<ByteArray> {
			// Find vo with id.
			var len:uint = _paintingData.length;
			var vo:PaintingVO;
			for( var i:uint; i < len; ++i ) {
				vo = _paintingData[ i ];
				if( vo.id == id ) {
					return Vector.<ByteArray>( [ vo.colorImageARGB, vo.heightmapImageARGB, vo.sourceImageARGB ] );
				}
			}
			throw new Error( this, "unable to find saved painting with id: " + id );
		}
	}
}
