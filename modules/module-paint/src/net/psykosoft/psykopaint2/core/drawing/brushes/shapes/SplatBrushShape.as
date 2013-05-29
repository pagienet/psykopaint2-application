package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplatBrushShape extends EmbeddedBrushShapeATF
	{
		//[Embed(source="assets/brushset5.png", mimeType="image/png")]
		[Embed( source = "assets/brushset5.atf", mimeType="application/octet-stream")]
		protected var SourceImage : Class;

		[Embed(source="assets/brushset5_NRM2.atf", mimeType="application/octet-stream")]
		protected var SourceNormalHeightMap : Class;

		public function SplatBrushShape(context3D : Context3D)
		{
			super(context3D, "splat", SourceImage, SourceNormalHeightMap, 512 );
			_variationFactors[0] = 2;
			_variationFactors[1] = 3;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_rotationRange = 0.15;
		}

	}
}



