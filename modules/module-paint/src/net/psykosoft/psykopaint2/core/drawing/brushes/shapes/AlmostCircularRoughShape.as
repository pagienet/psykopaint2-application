package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class AlmostCircularRoughShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "almost circular rough";

		
		[Embed(source="assets/atf/notentirelycircular18_8x8.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/notentirelycircularheight10_8x8.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function AlmostCircularRoughShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = 0.05;
		}
	}
}
