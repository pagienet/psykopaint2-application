package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class BasicCircularShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "basic circular";

		
		[Embed(source="assets/atf/basic_circle2.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		

		public function BasicCircularShape(context3D : Context3D)
		{ 
			super(context3D, NAME, SourceMap,SourceMap,256,1,1);
		}

		
	}
}
