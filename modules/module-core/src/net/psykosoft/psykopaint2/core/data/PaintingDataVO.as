package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;

	public class PaintingDataVO
	{
		public var surfaces:Vector.<ByteArray>;
		public var fullWidth:uint;
		public var fullHeight:uint;

		public function PaintingDataVO() {
			super();
		}
	}
}
