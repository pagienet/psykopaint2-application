package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class LineBrushShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "line";

		
		[Embed(source="assets/lines3.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/lines3_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function LineBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,128,4,16);
			rotationRange = 0;
		}
	}
}
