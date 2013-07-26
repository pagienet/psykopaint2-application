package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplotchBrushShape extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/brushset1.atf", mimeType="application/octet-stream")]
		protected var SourceImage:Class;

		[Embed(source="assets/brushset1_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function SplotchBrushShape(context3D : Context3D)
		{
			super(context3D, "splotch", SourceImage, SourceNormalSpecularMap, 512, 4, 4);
		}
	}
}
