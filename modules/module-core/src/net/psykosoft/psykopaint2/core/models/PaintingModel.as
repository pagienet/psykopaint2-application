package net.psykosoft.psykopaint2.core.models
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;

	public class PaintingModel
	{
		[Inject]
		public var notifyPaintingDataRetrievedSignal : NotifyPaintingDataRetrievedSignal;

		private var _paintingData : Array;
		private var _focusedPaintingId : String = "";
		private var _sortingDirty : Boolean;
		private var _sortedData:Vector.<PaintingInfoVO>;

		public function PaintingModel()
		{
			super();
			_paintingData = [];
		}

		public function setPaintingCollection(data : Vector.<PaintingInfoVO>) : void
		{
			for (var i : uint = 0; i < data.length; ++i)
				_paintingData[data[i].id] = data[i];

			_sortingDirty = true;
			notifyPaintingDataRetrievedSignal.dispatch( getSortedPaintingCollection() );
		}

		public function getPaintingCollection() : Vector.<PaintingInfoVO>
		{
			var collection : Vector.<PaintingInfoVO> = new Vector.<PaintingInfoVO>();
			var i : uint = 0;

			for each(var vo : PaintingInfoVO in _paintingData)
				collection[i++] = vo;

			return collection;
		}

		public function getSortedPaintingCollection() : Vector.<PaintingInfoVO>
		{
			if( _sortingDirty ) {
				_sortedData = getPaintingCollection();
				_sortedData.sort( sortOnLastSaved );
				_sortingDirty = false;
			}

			return _sortedData;
		}

		public function getVoWithId(id : String) : PaintingInfoVO
		{
			// Find vo with id.
			var vo : PaintingInfoVO = _paintingData[id];
//			if (!vo)
//				throw new Error(this, "unable to find saved painting with id: " + id);
			return vo;
		}

		public function deleteVoWithId(id : String) : void
		{
			_paintingData[id] = null;
			delete _paintingData[id];
			_sortingDirty = true;
		}

		/**
		 * Adds or updates a painting vo.
		 * @param vo
		 */
		public function updatePaintingInfo(vo : PaintingInfoVO) : void
		{
			if (vo.id == PaintingInfoVO.DEFAULT_VO_ID)
				throw "PaintingInfoVO id not set";

			if (_paintingData[vo.id]) _paintingData[vo.id].dispose();
			_paintingData[vo.id] = vo;
			_sortingDirty = true;
		}

		public function dirtyDateSorting():void {
			_sortingDirty = true;
		}

		public function get focusedPaintingId() : String
		{
			return _focusedPaintingId;
		}

		public function set focusedPaintingId(id : String) : void
		{
			_focusedPaintingId = id;
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
	}
}
