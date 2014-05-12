package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class SumiShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "sumi";

		
		[Embed(source="assets/sumi_8x8.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/sumi_8x8_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SumiShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = Math.PI;
		}
	}
}
