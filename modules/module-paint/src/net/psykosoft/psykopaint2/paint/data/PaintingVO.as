package net.psykosoft.psykopaint2.paint.data
{

	import flash.display.BitmapData;

	public class PaintingVO
	{
		public var diffuseImage:BitmapData;
		public var heightmapImage:BitmapData;
		public var compositeImage:BitmapData;
		public var diffuseThumb:BitmapData;
		public var heightmapThumb:BitmapData;
		public var compositeThumb:BitmapData;
		public var id:String;

		public function PaintingVO() {
			super();
		}
	}
}
