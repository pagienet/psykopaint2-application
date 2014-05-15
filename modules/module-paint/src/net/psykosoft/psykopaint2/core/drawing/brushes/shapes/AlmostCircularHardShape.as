package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class AlmostCircularHardShape extends EmbeddedBrushShapeATF
	{
		
		public static const NAME:String="almost circular hard";
		
		[Embed(source="assets/atf/notentirelycircular1.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		//[Embed(source="assets/notentirelycircularheight9_8x8.png", mimeType="image/png")]
		[Embed(source="assets/atf/notentirelycircular2_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function AlmostCircularHardShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,1024,8,8);
			rotationRange = Math.PI*2;
		}
	}
}
