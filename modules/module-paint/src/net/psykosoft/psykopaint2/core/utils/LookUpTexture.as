package net.psykosoft.psykopaint2.core.utils
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class LookUpTexture
	{
		private var _lookUpFunction : Function;
		private var _texture : Texture;
		private var _width : int;
		private var _height : int;

		// lookUpFunction(x, y, data);
		public function LookUpTexture(width : int, height : int, lookUpFunction : Function, context : Context3D)
		{
			_width = width;
			_height = height;
			_texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
			_lookUpFunction = lookUpFunction;
			update();
		}

		public function update() : void
		{
			var ba : ByteArray = new ByteArray();
			var color : Vector.<Number> = new Vector.<Number>();

			for (var y : int = 0; y < _height; ++y) {
				for (var x : int = 0; x < _width; ++x) {
					_lookUpFunction(x/_width, y/_height, color);
					ba.writeByte(int(color[2]*0xff) & 0xff);
					ba.writeByte(int(color[1]*0xff) & 0xff);
					ba.writeByte(int(color[0]*0xff) & 0xff);
					ba.writeByte(int(color[3]*0xff) & 0xff);
				}
			}

			_texture.uploadFromByteArray(ba, 0);
		}

		public function get texture() : Texture
		{
			return _texture;
		}

		public function dispose() : void
		{
			_texture.dispose();
		}
	}
}
