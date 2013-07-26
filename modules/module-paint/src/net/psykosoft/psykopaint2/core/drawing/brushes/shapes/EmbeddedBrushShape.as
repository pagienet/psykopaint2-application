package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	public class EmbeddedBrushShape extends AbstractBrushShape
	{
		protected var _colorAsset : Class;
		protected var _normalSpecularAsset : Class;

		public function EmbeddedBrushShape(context3D : Context3D, id : String, colorAsset : Class, normalSpecularAsset : Class, size:int, cols:int = 1, rows:int = 1 )
		{
			super(context3D, id, 1,size,1,1);
			_colorAsset = colorAsset;
			_normalSpecularAsset = normalSpecularAsset;
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var source:BitmapData = (new _colorAsset() as Bitmap ).bitmapData;
			uploadMips(_textureSize, source, texture);
			source.dispose();
		}

		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var source:BitmapData = (new _normalSpecularAsset() as Bitmap ).bitmapData;
			uploadMips(_textureSize, source, texture);
			source.dispose();
		}
	}
}
