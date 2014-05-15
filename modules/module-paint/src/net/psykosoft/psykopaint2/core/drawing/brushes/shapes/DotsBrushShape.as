package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class DotsBrushShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "dots";

		
		[Embed(source="assets/atf/dots.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/dots_height2.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function DotsBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,128,16,16);
			rotationRange = Math.PI;
		}
	}
}
