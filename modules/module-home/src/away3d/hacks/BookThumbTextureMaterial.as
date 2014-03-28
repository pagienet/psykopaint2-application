package away3d.hacks
{
	import away3d.arcane;
	import away3d.materials.MaterialBase;
	import away3d.textures.Texture2DBase;

	use namespace arcane;

	public class BookThumbTextureMaterial extends MaterialBase
	{
		private var _pass : BookThumbTextureMaterialPass;

		public function BookThumbTextureMaterial(texture : Texture2DBase)
		{
			_pass = new BookThumbTextureMaterialPass(texture);
			addPass(_pass);
		}

		public function get texture() : Texture2DBase
		{
			return _pass.texture;
		}

		public function set texture(value : Texture2DBase) : void
		{
			_pass.texture = value;
		}
	}
}
