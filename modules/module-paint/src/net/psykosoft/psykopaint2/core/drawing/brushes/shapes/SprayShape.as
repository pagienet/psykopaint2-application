package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class SprayShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "spray";

		
		[Embed(source="assets/spray2.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/spray2_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SprayShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,3,3);
			rotationRange = Math.PI;
		}
	}
}
