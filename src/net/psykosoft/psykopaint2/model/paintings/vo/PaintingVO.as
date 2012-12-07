package net.psykosoft.psykopaint2.model.paintings.vo
{

	import flash.display.BitmapData;

	public class PaintingVO
	{
		public var diffuseBitmap:BitmapData;
		public var normalsBitmap:BitmapData;
		public var specularBitmap:BitmapData;

		public function PaintingVO( diffuseBitmap:BitmapData, normalsBitmap:BitmapData, specularBitmap:BitmapData ) {
			this.diffuseBitmap = diffuseBitmap;
			this.normalsBitmap = normalsBitmap;
			this.specularBitmap = specularBitmap;
		}
	}
}
