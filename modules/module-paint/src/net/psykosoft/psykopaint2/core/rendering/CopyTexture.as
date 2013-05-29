package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;

	public class CopyTexture extends FullTextureFilter
	{
		private static var _instance : CopyTexture;

		public function CopyTexture()
		{
		}

		// use a static method because this is so universally used. (still bleh, tho)
		public static function copy(source : TextureBase, context3D : Context3D, width : Number = 1, height : Number = 1) : void
		{
			_instance ||= new CopyTexture();
			_instance.draw(source, context3D, width, height);
		}

		public static function dispose() : void
		{
			if (_instance) _instance.dispose();
		}

		override protected function getFragmentCode() : String
		{
			// source image is always in fs0
			return "tex oc, v0, fs0 <2d, nearest, mipnone>";
		}
	}
}
