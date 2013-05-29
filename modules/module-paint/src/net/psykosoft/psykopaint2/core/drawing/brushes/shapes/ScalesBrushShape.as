package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;


	public class ScalesBrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/scales_color.png", mimeType="image/png")]
		protected var SourceImage:Class;

		[Embed(source="assets/scales_normal.png", mimeType="image/png")]
		protected var SourceNormalHeightMap:Class;

		public function ScalesBrushShape(context3D : Context3D)
		{
			super(context3D, "scales", SourceImage, SourceNormalHeightMap);
			
		}
	}
}
