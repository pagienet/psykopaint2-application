package net.psykosoft.psykopaint2.core.data
{

	public class RetrievePaintingsVO
	{
		public var paintingVos:Vector.<PaintingInfoVO>;
		public var paintingFileNames:Vector.<String>;
		public var numPaintingFiles:uint;
		public var paintingInfoBeingReadIndex:uint;

		public function RetrievePaintingsVO() {
			super();
		}

		public function dispose():void {
			paintingFileNames = null;
		}
	}
}
