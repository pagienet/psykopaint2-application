package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;
	import net.psykosoft.psykopaint2.core.utils.LookUpTexture;

	public class SpecularBlinnModel extends BDRFModel
	{
		[Embed(source="/../shaders/agal/CanvasSpecularBlinn.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		protected var _fragmentShaderData : Vector.<Number>;

		private var _lookUp : LookUpTexture;
		private var _glossiness : Number;
		private var _specularColorR : Number;
		private var _specularColorG : Number;
		private var _specularColorB : Number;

		public function SpecularBlinnModel()
		{
			super();
			_fragmentShaderData = new <Number>[0, 0, 0, 0];
		}

		override public function getFragmentCode() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
			if (_lookUp && isLookUpInvalid(lightingModel)) {
				_lookUp.dispose();
				_lookUp = null;
			}

			_glossiness = lightingModel.glossiness;
			_specularColorR = lightingModel.specularColorR;
			_specularColorG = lightingModel.specularColorG;
			_specularColorB = lightingModel.specularColorB;
		}

		private function isLookUpInvalid(lightingModel : LightingModel) : Boolean
		{
			return 	_glossiness != lightingModel.glossiness ||
					_specularColorR != lightingModel.specularColorR ||
					_specularColorG != lightingModel.specularColorG ||
					_specularColorB != lightingModel.specularColorB;
		}

		override public function setRenderState(context : Context3D) : void
		{
			if (!_lookUp) initLookUp(context);
			// add
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 15, _fragmentShaderData, 1);
			context.setTextureAt(3, _lookUp.texture);
		}

		override public function clearRenderState(context : Context3D) : void
		{
			context.setTextureAt(3, null);
		}

		private function initLookUp(context : Context3D) : void
		{
			_lookUp = new LookUpTexture(128, 64, getSpecularColor, context);
		}

		private function getSpecularColor(nDotH : Number, y : Number, color : Vector.<Number>) : void
		{
			var exponent : Number = y*_glossiness;
			var specularStrength : Number = Math.pow(nDotH, exponent);
			color[0] = _specularColorR * specularStrength;
			color[1] = _specularColorG * specularStrength;
			color[2] = _specularColorB * specularStrength;
			color[3] = 0;
		}
	}
}
