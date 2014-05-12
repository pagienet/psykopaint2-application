package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class VectorSplatShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "vectorsplat";

		
		[Embed(source="assets/vectorsplat.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/vectorsplat_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function VectorSplatShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,256,2,2);
			rotationRange = Math.PI;
		}
	}
}
