package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class LineBrushShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "line";

		
		[Embed(source="assets/atf/lines3.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/lines3_height.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function LineBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,128,4,16);
			rotationRange = 0;
		}
	}
}
