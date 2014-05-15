package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplatBrushShape2 extends EmbeddedBrushShape
	{
		[Embed(source="assets/png/brushset2.png", mimeType="image/png")]
		protected var SourceImage:Class;

		[Embed(source="assets/png/brushset2_NRM.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SplatBrushShape2(context3D : Context3D)
		{
			super(context3D, "splat2", SourceImage, SourceNormalSpecularMap,512,3,3);
			_rotationRange = 0.5;
		}
	}
}
