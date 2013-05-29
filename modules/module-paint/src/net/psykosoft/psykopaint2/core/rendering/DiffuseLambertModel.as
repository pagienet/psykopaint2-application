package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class DiffuseLambertModel extends BDRFModel
	{
		[Embed(source="/../shaders/agal/CanvasDiffuseLambert.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		private var _fragmentShaderData : Vector.<Number>;

		public function DiffuseLambertModel()
		{
			super();
			_fragmentShaderData = new <Number>[0, 0, 0, 1];
		}

		override public function getFragmentCode() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}


		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
			// light colour
			_fragmentShaderData[0] = lightingModel.diffuseColorR;
			_fragmentShaderData[1] = lightingModel.diffuseColorG;
			_fragmentShaderData[2] = lightingModel.diffuseColorB;
		}


		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, _fragmentShaderData, 1);
		}
	}
}
