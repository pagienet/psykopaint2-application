package away3d.hacks
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.textures.Texture2DBase;

	import flash.display3D.textures.RectangleTexture;

	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;

	public class NativeRectTexture extends RectTextureBase
	{
		private var _texture : RectangleTexture;

		public function NativeRectTexture(texture : RectangleTexture)
		{
			super();
			_texture = texture;
		}

		override public function getTextureForStage3D(stage3DProxy : Stage3DProxy) : TextureBase
		{
			return _texture;
		}


		override public function dispose() : void
		{
			super.dispose();
			_texture.dispose();
		}

		public function get texture() : RectangleTexture
		{
			return _texture;
		}
	}
}
