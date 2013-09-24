package net.psykosoft.psykopaint2.core.data
{


	public class RetrievePaintingsDataProcessModel
	{
		public var paintingVos:Vector.<PaintingInfoVO>;
		public var paintingInfoFileNames:Vector.<String>;
		public var numPaintingFiles:uint;
		public var paintingInfoBeingReadIndex:uint;

		public function RetrievePaintingsDataProcessModel() {
		}

		public function dispose():void {
			numPaintingFiles = 0;
			paintingInfoBeingReadIndex = 0;
			paintingInfoFileNames = null;
			paintingVos = null;
		}
	}
}
