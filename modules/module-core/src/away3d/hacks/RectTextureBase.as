package away3d.hacks
{
	import away3d.textures.Texture2DBase;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;

	public class RectTextureBase extends Texture2DBase
	{
		public function RectTextureBase()
		{
			super();
		}

		override protected function createTexture(context:Context3D):TextureBase
		{
			return context.createRectangleTexture(_width, _height, Context3DTextureFormat.BGRA, false);
		}
	}
}
