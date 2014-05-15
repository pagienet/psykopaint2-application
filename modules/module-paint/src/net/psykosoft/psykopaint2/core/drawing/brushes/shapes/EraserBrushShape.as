package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class EraserBrushShape extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/atf/NoiseShape.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/NoiseShape.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		
		public static var NAME:String = "eraser";

		public function EraserBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,2,2);

			rotationRange = Math.PI;
		}
	}
}
