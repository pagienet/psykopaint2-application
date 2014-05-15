package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class SplatterSprayShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "splatspray";
		
		[Embed(source="assets/atf/spray1.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/spray1_height.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function SplatterSprayShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,256,1,1);
			rotationRange = 2*Math.PI;
		}
	}
}
