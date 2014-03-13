package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class PaintbrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/paintbrush5x5.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/paintbrush5x5_height.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function PaintbrushShape(context3D : Context3D)
		{
			super(context3D, "paintbrush", SourceMap,SourceNormalSpecularMap,1024,5,5);
			rotationRange = Math.PI;
		}
	}
}
