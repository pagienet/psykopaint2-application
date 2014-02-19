package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class AlmostCircularHardShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/notentirelycircular5.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/notentirelycircularheight2.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function AlmostCircularHardShape(context3D : Context3D)
		{
			super(context3D, "almost circular hard", SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = 0;
		}
	}
}
