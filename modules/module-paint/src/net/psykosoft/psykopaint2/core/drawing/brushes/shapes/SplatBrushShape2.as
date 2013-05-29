package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	
	public class SplatBrushShape2 extends EmbeddedBrushShape
	{
		[Embed(source="assets/brushset2.png", mimeType="image/png")]
		protected var SourceImage:Class;

		[Embed(source="assets/brushset2_NRM.png", mimeType="image/png")]
		protected var SourceNormalHeightMap:Class;

		public function SplatBrushShape2(context3D : Context3D)
		{
			super(context3D, "splat2", SourceImage, SourceNormalHeightMap);
			_variationFactors[0] = 3;
			_variationFactors[1] = 3;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_rotationRange = 0.5;
		}
	}
}
