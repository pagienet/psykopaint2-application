package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	
	public class SprayShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "spray";

		
		[Embed(source="assets/atf/spray2.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/spray2_height.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function SprayShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,3,3);
			rotationRange = Math.PI;
		}
	}
}
