package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	public class SavingProcessModel
	{
		public var paintingId:String;
		public var infoBytes:ByteArray;
		public var dataBytes:ByteArray;

		public function toString():String {
			return "SavePaintingVO - [ paintingId: " + paintingId + " ]";
		}

		public function dispose():void {
			if( infoBytes ) infoBytes.clear();
			if( dataBytes ) dataBytes.clear();
			infoBytes = null;
			dataBytes = null;
			paintingId = null;
		}
	}
}
