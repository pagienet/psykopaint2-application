package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class EraserBrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/NoiseShape.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/NoiseShape3.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		
		public static var NAME:String = "eraser";

		public function EraserBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,128,16,16);
			rotationRange = Math.PI;
		}
	}
}
