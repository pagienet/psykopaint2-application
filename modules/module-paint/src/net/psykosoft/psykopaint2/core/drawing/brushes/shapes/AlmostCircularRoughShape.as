package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class AlmostCircularRoughShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/notentirelycircular10.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/notentirelycircularheight6.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function AlmostCircularRoughShape(context3D : Context3D)
		{
			super(context3D, "almost circular rough", SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = 0.10;
		}
	}
}
