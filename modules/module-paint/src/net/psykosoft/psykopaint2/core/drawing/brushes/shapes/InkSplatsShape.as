package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class InkSplatsShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/ink_splats.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/ink_splats_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function InkSplatsShape(context3D : Context3D)
		{
			super(context3D, "inksplats", SourceMap,SourceNormalSpecularMap,512,4,3);
			rotationRange = Math.PI;
		}
	}
}
