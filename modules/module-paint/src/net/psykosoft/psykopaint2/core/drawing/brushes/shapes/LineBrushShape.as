package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class LineBrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/lines2.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/lines2_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function LineBrushShape(context3D : Context3D)
		{
			super(context3D, "line", SourceMap,SourceNormalSpecularMap,64,1,8);
			rotationRange = 0;
		}
	}
}
