package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class EmbeddedBrushShapeATF extends AbstractBrushShape
	{
		private var _colorAsset : Class;
		private var _normalSpecularAsset : Class;

		public function EmbeddedBrushShapeATF(context3D : Context3D, id : String, colorAsset : Class, normalSpecularAsset : Class, size:int, cols:int = 1, rows:int = 1 )
		{
			super(context3D, id, 1, size, cols, rows)
			_colorAsset = colorAsset;
			_normalSpecularAsset = normalSpecularAsset;
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var textureAsset:ByteArray = new _colorAsset() as ByteArray;
			texture.uploadCompressedTextureFromByteArray(textureAsset, 0);
		}

		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var textureAsset:ByteArray = new _normalSpecularAsset() as ByteArray;
			texture.uploadCompressedTextureFromByteArray(textureAsset, 0);
		}
	}
}
