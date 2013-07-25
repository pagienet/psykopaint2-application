package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class PaintBrushShape1 extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/brushset8.atf", mimeType="application/octet-stream")]
		protected var SourceImage:Class;

		[Embed(source="assets/brushset8_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function PaintBrushShape1(context3D : Context3D)
		{
			super(context3D, "paint1", SourceImage, SourceNormalSpecularMap ,512);
			_variationFactors[0] = 2;
			_variationFactors[1] = 8;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_variationFactors[4] = Math.atan2(_variationFactors[3],_variationFactors[2]);
			_rotationRange = 0.05;
		}
	}
}
