package net.psykosoft.psykopaint2.core.models
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingDeletionSignal;

	public class PaintingModel
	{
		[Inject]
		public var notifyPaintingDataSetSignal:NotifyPaintingDataSetSignal;
		
		[Inject]
		public var requestPaintingDeletionSignal:RequestPaintingDeletionSignal;

		private var _paintingData:Object;
		private var _activePaintingId:String;

		[PostConstruct]
		public function init() : void
		{
			requestPaintingDeletionSignal.add( onPaintingDeleted );
		}
		
		private function onPaintingDeleted( id:String ):void
		{
			PaintingInfoVO(_paintingData[id]).dispose();
			delete _paintingData[id];
		}
		
		public function disposePaintingCollection():void {
			for each( var vo:PaintingInfoVO in _paintingData )
				vo.dispose();

			_paintingData = null;
		}

		public function setPaintingCollection( data:Vector.<PaintingInfoVO> ):void {

			trace( this, "setPaintingCollection()" );

			if( !_paintingData ) _paintingData = {};

			for( var i:uint = 0; i < data.length; ++i ) {
				_paintingData[data[i].id] = data[i];
			}

			notifyPaintingDataSetSignal.dispatch( getSortedPaintingCollection() );
		}

		public function getSortedPaintingCollection():Vector.<PaintingInfoVO> {
			trace( this, "getSortedPaintingCollection()" );
			var sortedData : Vector.<PaintingInfoVO> = getPaintingCollection();
			sortedData.sort( sortOnLastSaved );
			return sortedData;
		}

		private function getPaintingCollection():Vector.<PaintingInfoVO> {
			var collection:Vector.<PaintingInfoVO> = new Vector.<PaintingInfoVO>();
			var i:uint = 0;

			for each( var vo:PaintingInfoVO in _paintingData )
				collection[i++] = vo;

			return collection;
		}

		public function getVoWithId( id:String ):PaintingInfoVO {
			var vo:PaintingInfoVO = _paintingData[id];
			return vo;
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function sortOnLastSaved( paintingVOA:PaintingInfoVO, paintingVOB:PaintingInfoVO ):Number {
			if( paintingVOA.lastSavedOnDateMs > paintingVOB.lastSavedOnDateMs ) return -1;
			else if( paintingVOA.lastSavedOnDateMs < paintingVOB.lastSavedOnDateMs ) return 1;
			else {
				if( paintingVOA.id > paintingVOB.id ) return -1;
				else return 1;
			}
		}

		public function get activePaintingId():String {
			return _activePaintingId;
		}

		public function set activePaintingId( value:String ):void {
			_activePaintingId = value;
		}
	}
}
