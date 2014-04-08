package away3d.hacks
{
	import away3d.arcane;
	import away3d.materials.MaterialBase;
	import away3d.textures.Texture2DBase;
	import away3d.textures.TextureProxyBase;

	use namespace arcane;

	public class FlatTextureMaterial extends MaterialBase
	{
		private var _pass : FlatTextureMaterialPass;

		public function FlatTextureMaterial(texture : TextureProxyBase)
		{
			_pass = new FlatTextureMaterialPass(texture);
			addPass(_pass);
		}

		public function get texture() : TextureProxyBase
		{
			return _pass.texture;
		}

		public function set texture(value : TextureProxyBase) : void
		{
			_pass.texture = value;
		}


		override public function set blendMode(value:String):void
		{
			super.blendMode = value;
			_pass.setBlendMode(value);
		}
	}
}
