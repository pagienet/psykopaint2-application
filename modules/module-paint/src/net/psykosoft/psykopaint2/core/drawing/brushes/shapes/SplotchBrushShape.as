package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplotchBrushShape extends EmbeddedBrushShape
	{
		//[Embed(source="assets/brushset1.png", mimeType="application/octet-stream")]
		[Embed(source="assets/brushset1.png", mimeType="image/png")]
		protected var SourceMap:Class;

		//[Embed(source="assets/brushset1_hsp.png", mimeType="application/octet-stream")]
		[Embed(source="assets/brushset1_test1.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SplotchBrushShape(context3D : Context3D)
		{
			super(context3D, "splotch", SourceMap, SourceNormalSpecularMap, 512, 4, 4);
			rotationRange = Math.PI*2;
		}
	}
}
