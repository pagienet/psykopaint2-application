package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class AmbientOffsetEnvMapModel extends BDRFModel
	{
		protected var _fragmentShaderData : Vector.<Number>;

		[Embed(source="/../shaders/agal/CanvasAmbientOffsetEnvMap.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		private var _envMap : Texture;

		public function AmbientOffsetEnvMapModel()
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
			// ambient colour
			_fragmentShaderData[0] = lightingModel.ambientColorR;
			_fragmentShaderData[1] = lightingModel.ambientColorG;
			_fragmentShaderData[2] = lightingModel.ambientColorB;
			_envMap = lightingModel.environmentMap;
		}

		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, _fragmentShaderData, 1);
			context.setTextureAt(4, _envMap);
		}

		override public function clearRenderState(context : Context3D) : void
		{
			context.setTextureAt(4, null);
		}
	}
}
