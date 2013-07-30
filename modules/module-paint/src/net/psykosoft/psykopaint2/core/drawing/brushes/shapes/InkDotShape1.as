package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class InkDotShape1 extends EmbeddedYuvMatchingBrushShape
	{
		[Embed(source="assets/InkDots1.png", mimeType="image/png")]
		protected var SourceImage:Class;
		
		public function InkDotShape1(context3D : Context3D)
		{
			super(context3D, "inkdots1", SourceImage, null, 512,4,4);
			uvColorData = Vector.<int>([235,55,137,193,68,139,217,56,152,188,44,171,165,103,71,184,73,102,172,81,185,146,99,202,159,138,117,208,108,138,178,106,151,146,140,179,164,168,63,129,192,97,167,168,111,165,153,147]);
		}

		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, true,0xff00007f);
			uploadMips(_textureSize, bitmapData, texture);
			bitmapData.dispose();
		}
		
	}
}
