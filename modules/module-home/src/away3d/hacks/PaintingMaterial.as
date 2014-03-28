package away3d.hacks
{
	import away3d.materials.MaterialBase;
	import away3d.textures.Texture2DBase;

	public class PaintingMaterial extends MaterialBase
	{
		private var _pass : PaintingMaterialPass;

		public function PaintingMaterial()
		{
			addPass(_pass = new PaintingMaterialPass());
		}

		public function get albedoTexture() : RectTextureBase
		{
			return _pass.albedoTexture;
		}

		public function set albedoTexture(value : RectTextureBase) : void
		{
			_pass.albedoTexture = value;
		}

		public function get normalSpecularTexture() : RectTextureBase
		{
			return _pass.normalSpecularTexture;
		}

		public function set normalSpecularTexture(value : RectTextureBase) : void
		{
			_pass.normalSpecularTexture = value;
		}

		public function get ambientColor() : uint
		{
			return _pass.ambientColor;
		}

		public function set ambientColor(value : uint) : void
		{
			_pass.ambientColor = value;
		}

		public function get specular() : Number
		{
			return _pass.specular;
		}

		public function set specular(value : Number) : void
		{
			_pass.specular = value;
		}

		public function get gloss() : Number
		{
			return _pass.gloss;
		}

		public function set gloss(value : Number) : void
		{
			_pass.gloss = value;
		}

		public function get enableStencil() : Boolean
		{
			return _pass.enableStencil;
		}

		public function set enableStencil(enableStencil : Boolean) : void
		{
			_pass.enableStencil = enableStencil;
		}

		public function get stencilReferenceValue() : int
		{
			return _pass.stencilReferenceValue;
		}

		public function set stencilReferenceValue(stencilReferenceValue : int) : void
		{
			_pass.stencilReferenceValue = stencilReferenceValue;
		}

		public function get stencilCompareMode() : String
		{
			return _pass.stencilCompareMode;
		}

		public function set stencilCompareMode(stencilCompareMode : String) : void
		{
			_pass.stencilCompareMode = stencilCompareMode;
		}

		public function get bumpiness() : Number
		{
			return _pass.bumpiness;
		}

		public function set bumpiness(value : Number) : void
		{
			_pass.bumpiness = value;
		}
	}
}
