package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;

	public class PaintingModel
	{
		[Inject]
		public var notifyPaintingDataRetrievedSignal : NotifyPaintingDataRetrievedSignal;

		private var _paintingData : Array;
		private var _focusedPaintingId : String = "";

		public function PaintingModel()
		{
			super();
			_paintingData = new Array();
		}

		public function setPaintingCollection(data : Vector.<PaintingInfoVO>) : void
		{
			for (var i : uint = 0; i < data.length; ++i)
				_paintingData[data[i].id] = data[i];

			notifyPaintingDataRetrievedSignal.dispatch(data);
		}

		public function getPaintingCollection() : Vector.<PaintingInfoVO>
		{
			var collection : Vector.<PaintingInfoVO> = new Vector.<PaintingInfoVO>();
			var i : uint = 0;

			for each(var vo : PaintingInfoVO in _paintingData)
				collection[i++] = vo;

			return collection;
		}

		public function getVoWithId(id : String) : PaintingInfoVO
		{
			// Find vo with id.
			var vo : PaintingInfoVO = _paintingData[id];
			if (!vo)
				throw new Error(this, "unable to find saved painting with id: " + id);
			return vo;
		}

		public function deleteVoWithId(id : String) : void
		{
			_paintingData[id] = null;
			delete _paintingData[id];
		}

		/**
		 * Adds or updates a painting vo.
		 * @param vo
		 */
		public function updatePaintingInfo(vo : PaintingInfoVO) : void
		{
			if (vo.id == PaintingInfoVO.DEFAULT_VO_ID)
				throw "PaintingInfoVO id not set";

			_paintingData[vo.id] = vo;
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

		public function sortOnLastSaved( paintingVOA:PaintingInfoVO, paintingVOB:PaintingInfoVO ):Number {
			if( paintingVOA.lastSavedOnDateMs > paintingVOB.lastSavedOnDateMs ) return -1;
			else if( paintingVOA.lastSavedOnDateMs < paintingVOB.lastSavedOnDateMs ) return 1;
			else {
				if( paintingVOA.id > paintingVOB.id ) return -1;
				else return 1;
			}
		}
	}
}
