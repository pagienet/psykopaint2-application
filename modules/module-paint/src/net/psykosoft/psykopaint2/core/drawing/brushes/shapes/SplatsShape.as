package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class SplatsShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/splat.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/splat_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SplatsShape(context3D : Context3D)
		{
			super(context3D, "splats", SourceMap,SourceNormalSpecularMap,512,2,2);
			rotationRange = Math.PI;
		}
	}
}
