package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class DotsBrushShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "dots";

		
		[Embed(source="assets/dots.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/dots_height2.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function DotsBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,128,16,16);
			rotationRange = Math.PI;
		}
	}
}
