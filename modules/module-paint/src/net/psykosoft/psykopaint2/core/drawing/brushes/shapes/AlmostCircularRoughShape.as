package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class AlmostCircularRoughShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/notentirelycircular18_8x8.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/notentirelycircularheight10_8x8.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function AlmostCircularRoughShape(context3D : Context3D)
		{
			super(context3D, "almost circular rough", SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = 0.05;
		}
	}
}
