package away3d.hacks
{
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;

	public class ByteArrayRectTexture extends RectTextureBase
	{
		private var _byteArray : ByteArray;

		public function ByteArrayRectTexture(byteArray : ByteArray, width : int, height : int)
		{
			super();

			setByteArray(byteArray, width, height);
		}

		public function get byteArray() : ByteArray
		{
			return _byteArray;
		}

		public function setByteArray(value : ByteArray, width : int, height : int) : void
		{
			if (value == _byteArray) return;

			invalidateContent();
			setSize(width, height);

			_byteArray = value;
			_byteArray.length =  width * height * 4;
		}

		override protected function uploadContent(texture : TextureBase) : void
		{
			Texture(texture).uploadFromByteArray(_byteArray, 0, 0);
		}

		override public function dispose() : void
		{
			super.dispose();
			_byteArray = null;
		}
	}
}
