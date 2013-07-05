package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;

	public class PaintingDataVO
	{
		public var colorData:ByteArray;
		public var normalSpecularData:ByteArray;
		public var sourceBitmapData:ByteArray;
		public var width:uint;
		public var height:uint;

		public function PaintingDataVO()
		{
			super();
		}

		public function dispose() : void
		{
			colorData.clear();
			normalSpecularData.clear();
			sourceBitmapData.clear();
			colorData = null;
			normalSpecularData = null;
			sourceBitmapData = null;
		}
	}
}
