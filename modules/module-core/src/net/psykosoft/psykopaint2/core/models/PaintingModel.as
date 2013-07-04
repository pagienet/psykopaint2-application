package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;

	public class PaintingModel
	{
		[Inject]
		public var notifyPaintingDataRetrievedSignal:NotifyPaintingDataRetrievedSignal;

		private var _paintingData:Vector.<PaintingInfoVO>;
		private var _focusedPaintingId:String = "";

		public function PaintingModel() {
			super();
			_paintingData = new Vector.<PaintingInfoVO>();
		}

		public function setPaintingData( data:Vector.<PaintingInfoVO> ):void {
			_paintingData = data;
			notifyPaintingDataRetrievedSignal.dispatch( _paintingData );
		}

		public function getPaintingData():Vector.<PaintingInfoVO> {
			return _paintingData;
		}

		public function getVoWithId( id:String ):PaintingInfoVO {
			// Find vo with id.
			var len:uint = _paintingData.length;
			var vo:PaintingInfoVO;
			for( var i:uint; i < len; ++i ) {
				vo = _paintingData[ i ];
				if( vo.id == id ) {
					return vo;
				}
			}
			throw new Error( this, "unable to find saved painting with id: " + id );
		}

		public function deleteVoWithId( id:String ):void{

			// Nullify vo and identify index.
			var len:uint = _paintingData.length;
			var index:uint;
			var vo:PaintingInfoVO;
			for( var i:uint; i < len; ++i ) {
				vo = _paintingData[ i ];
				if( vo.id == id ) {
					index = i;
					vo = null;
					break;
				}
			}

			// Delete from array.
			_paintingData.splice( index, 1 );
		}

		public function addSinglePaintingData( vo:PaintingInfoVO ):void {
			_paintingData.push( vo );
		}

		public function get focusedPaintingId():String {
			return _focusedPaintingId;
		}

		public function set focusedPaintingId( id:String ):void {
			_focusedPaintingId = id;
		}
	}
}
