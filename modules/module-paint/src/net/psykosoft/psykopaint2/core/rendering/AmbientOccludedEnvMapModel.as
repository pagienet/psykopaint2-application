package net.psykosoft.psykopaint2.core.rendering
{
	import away3d.core.math.PoissonLookup;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class AmbientOccludedEnvMapModel extends BDRFModel
	{
		protected var _fragmentShaderData : Vector.<Number>;
		protected var _poissonData : Vector.<Number>;

		private var numSamples : int = 14;
		private var range : Number = 30	/2048;
		private var _envMap : Texture;

		public function AmbientOccludedEnvMapModel()
		{
			super();
			_fragmentShaderData = new <Number>[0, 0, 0, 0];
			_poissonData = new <Number>[];
			var distr : Vector.<Number> = PoissonLookup.getDistribution(numSamples);

			for (var i : int = 0; i < distr.length; ++i)
				_poissonData[i] = distr[i]*range;


		}

		override public function getFragmentCode() : String
		{
			var code : String = "add ft5.xy, v0.xy, fc20.xy\n" +
								"tex ft5, ft5.xyxy, fs2 <2d, clamp, linear, mipnone>\n" +
								"max ft4.x, ft4.x, fc0.y\n" +
								"min ft4.x, ft4.x, fc0.y\n";

			var registers : Array = [
				"fc20.xy", "fc20.zw",
				"fc21.xy", "fc21.zw",
				"fc22.xy", "fc22.zw",
				"fc23.xy", "fc23.zw",
				"fc24.xy", "fc24.zw",
				"fc25.xy", "fc25.zw",
				"fc26.xy", "fc26.zw"
			];

			for (var i : int = 1; i < numSamples; ++i) {
				code += "add ft5.xy, v0.xy, " + registers[i] + "\n" +
						"tex ft5, ft5.xyxy, fs2 <2d, clamp, linear, mipnone>\n" +
						"sub ft5.xy, ft5.xy, fc0.x\n" +
						"mul ft5.xy, ft5.xy, fc0.w\n" +	// multiply by bumpiness
						"mul ft4.y, ft5.x, ft0.x\n" +
						"mul ft4.z, ft5.y, ft0.y\n" +
						"add ft4.y, ft4.y, ft4.z\n" +
						"sat ft4.y, ft4.y\n" +
						"add ft4.x, ft4.x, ft4.y\n";
			}

			code += "mul ft4.x, ft4.x, fc10.w\n" +
					"sub ft4.x, fc0.z, ft4.x\n" +
					"mul ft5.xyz, ft0.xyz, fc0.x\n" +
					"add ft5.xy, ft5.xy, fc0.x\n" +
					"tex ft5, ft5.xyxy, fs4 <2d, clamp, linear, mipnone>\n" +
					"mul ft5, ft5, fc10\n" +
					"mul ft4.xyz, ft5.xyz, ft4.x\n";

			return code;
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
			// ambient colour
			_fragmentShaderData[0] = lightingModel.ambientColorR;
			_fragmentShaderData[1] = lightingModel.ambientColorG;
			_fragmentShaderData[2] = lightingModel.ambientColorB;
			_fragmentShaderData[3] = 10/numSamples;
			_envMap = lightingModel.environmentMap;
		}

		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, _fragmentShaderData, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 20, _poissonData, Math.ceil(numSamples/2));
			context.setTextureAt(4, _envMap);
		}

		override public function clearRenderState(context : Context3D) : void
		{
			context.setTextureAt(4, null);
		}
	}
}
