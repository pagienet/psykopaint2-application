package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class BasicCircularShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "basic circular";

		//[Embed(source="assets/png/basic_circle2.png", mimeType="image/png")]
		[Embed(source="assets/atf/basic_circle2.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		
		//[Embed(source="assets/png/basic_circle2_hsp.png", mimeType="image/png")]
		[Embed(source="assets/atf/basic_circle2_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalMap:Class;
		
		public function BasicCircularShape(context3D : Context3D)
		{ 
			super(context3D, NAME, SourceMap,SourceNormalMap,256,1,1);
		}

		
	}
}
