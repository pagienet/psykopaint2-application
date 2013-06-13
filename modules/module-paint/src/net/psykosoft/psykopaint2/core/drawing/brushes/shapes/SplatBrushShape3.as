package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplatBrushShape3 extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/brushset1.atf", mimeType="application/octet-stream")]
		protected var SourceImage:Class;

		[Embed(source="assets/brushset1_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function SplatBrushShape3(context3D : Context3D)
		{
			super(context3D, "splat3", SourceImage, SourceNormalSpecularMap ,512);
			_variationFactors[0] = 4;
			_variationFactors[1] = 4;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
		}
	}
}
