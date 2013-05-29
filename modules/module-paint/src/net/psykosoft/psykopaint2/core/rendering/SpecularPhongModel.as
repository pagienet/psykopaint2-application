package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class SpecularPhongModel extends BDRFModel
	{
		[Embed(source="/../shaders/agal/CanvasSpecularPhong.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		protected var _fragmentShaderData : Vector.<Number>;

		public function SpecularPhongModel()
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
			_fragmentShaderData[0] = lightingModel.specularStrength;
			_fragmentShaderData[1] = lightingModel.glossiness;
		}

		override public function setRenderState(context : Context3D) : void
		{
			// add
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 15, _fragmentShaderData, 1);
		}
	}
}
