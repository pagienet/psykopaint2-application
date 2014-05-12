package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class VarnishBrushShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "varnish";

		[Embed(source="assets/varnish.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		//[Embed(source="assets/notentirelycircularheight9_8x8.png", mimeType="image/png")]
		[Embed(source="assets/varnish_hsp.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function VarnishBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,256,1,1);
			rotationRange = Math.PI*2;
		}
	}
}
