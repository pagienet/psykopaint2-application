package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class LineBrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/lines3.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/lines3_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function LineBrushShape(context3D : Context3D)
		{
			super(context3D, "line", SourceMap,SourceNormalSpecularMap,128,1,32);
			rotationRange = 0;
		}
	}
}
