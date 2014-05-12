package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class NoisyBrushShape2 extends EmbeddedBrushShape
	{
		[Embed(source="assets/NoiseShape.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		//[Embed(source="assets/notentirelycircularheight9_8x8.png", mimeType="image/png")]
		[Embed(source="assets/NoiseShape3.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function NoisyBrushShape2(context3D : Context3D)
		{
			super(context3D, "noisy", SourceMap,SourceNormalSpecularMap,512,2,2);
			rotationRange = Math.PI*2;
		}
	}
}
