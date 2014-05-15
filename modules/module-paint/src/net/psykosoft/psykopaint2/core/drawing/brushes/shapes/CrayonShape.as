package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;

	
	public class CrayonShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "crayon";

		
		[Embed(source="assets/atf/crayon.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/crayon_height.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function CrayonShape(context3D : Context3D)
		{
			super(context3D,NAME, SourceMap,SourceNormalSpecularMap,256,2,2);
			rotationRange = Math.PI;
		}
	}
}
