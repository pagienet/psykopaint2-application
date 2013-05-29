package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class AmbientConstantModel extends BDRFModel
	{
		protected var _fragmentShaderData : Vector.<Number>;

		public function AmbientConstantModel()
		{
			super();
			_fragmentShaderData = new <Number>[0, 0, 0, 0];
		}

		override public function getFragmentCode() : String
		{
			return "";
		}

		override public function get outputRegister() : String
		{
			return "fc10";
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
			// ambient colour
			_fragmentShaderData[0] = lightingModel.ambientColorR;
			_fragmentShaderData[1] = lightingModel.ambientColorG;
			_fragmentShaderData[2] = lightingModel.ambientColorB;
		}

		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, _fragmentShaderData, 1);
		}
	}
}
