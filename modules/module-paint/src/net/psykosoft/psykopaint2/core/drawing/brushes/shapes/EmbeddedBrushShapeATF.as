package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class EmbeddedBrushShapeATF extends AbstractBrushShape
	{
		private var _colorAsset : Class;
		private var _normalHeightAsset : Class;

		public function EmbeddedBrushShapeATF(context3D : Context3D, id : String, colorAsset : Class, heightAsset : Class, size:int )
		{
			super(context3D, id, 1)
			_colorAsset = colorAsset;
			_normalHeightAsset = heightAsset;
			this.size = size;
			
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			
			var textureAsset:ByteArray = new _colorAsset() as ByteArray;
			texture.uploadCompressedTextureFromByteArray(textureAsset, 0);
			
			_scaleFactor = Math.sqrt(Math.pow( _variationFactors[2],2) +  Math.pow( _variationFactors[3],2));
		
		}

		override protected function uploadHeightMap(texture : Texture) : void
		{
			var textureAsset:ByteArray = new _normalHeightAsset() as ByteArray;
			texture.uploadCompressedTextureFromByteArray(textureAsset, 0);
		}
	}
}
