package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class PaintBrushShape1 extends EmbeddedBrushShape
	{
		//[Embed(source="assets/brushset8.atf", mimeType="application/octet-stream")]
		[Embed(source="assets/brushset8.png", mimeType="image/png")]
		protected var SourceImage:Class;

		//[Embed(source="assets/brushset8_hsp.atf", mimeType="application/octet-stream")]
		[Embed(source="assets/brushset8_hsp3.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function PaintBrushShape1(context3D : Context3D)
		{
			super(context3D, "paint1", SourceImage, SourceNormalSpecularMap, 512,2,8);
			_rotationRange = 0.05;
		}
	}
}
