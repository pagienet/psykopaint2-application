package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	public class EmbeddedBrushShape extends AbstractBrushShape
	{
		private var _colorAsset : Class;
		private var _normalSpecularAsset : Class;

		public function EmbeddedBrushShape(context3D : Context3D, id : String, colorAsset : Class, normalSpecularAsset : Class)
		{
			super(context3D, id, 1)
			_colorAsset = colorAsset;
			_normalSpecularAsset = normalSpecularAsset;
			var source:BitmapData = (new _colorAsset() as Bitmap ).bitmapData;
			this.size = source.width;
			source.dispose();
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var source:BitmapData = (new _colorAsset() as Bitmap ).bitmapData;

			uploadMips(_textureSize, source, texture);

			_scaleFactor = Math.sqrt(Math.pow( _variationFactors[2],2) +  Math.pow( _variationFactors[3],2));
			source.dispose();
		}

		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var source:BitmapData = (new _normalSpecularAsset() as Bitmap ).bitmapData;

			uploadMips(_textureSize, source, texture);

			_scaleFactor = Math.sqrt(Math.pow( _variationFactors[2],2) +  Math.pow( _variationFactors[3],2));
			source.dispose();
		}
	}
}
