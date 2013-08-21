package net.psykosoft.psykopaint2.core.rendering
{
	import away3d.core.math.PoissonLookup;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class AOShadowModel extends BDRFModel
	{
		protected var _fragmentShaderData : Vector.<Number>;
		protected var _poissonData : Vector.<Number>;

		private var numSamples : int = 3;
		private var range : Number = 5	/ 2048;

		public function AOShadowModel()
		{
			super();
			_fragmentShaderData = new <Number>[0, 0, 0, 10/numSamples];
			_poissonData = new <Number>[];
			var distr : Vector.<Number> = PoissonLookup.getDistribution(numSamples);

			for (var i : int = 0; i < distr.length; ++i)
				_poissonData[i] = distr[i]*range;
		}

		override public function getFragmentCode() : String
		{
			var code : String = "add ft5.xy, v0.xy, fc21.xy\n" +
								"tex ft5, ft5.xyxy, fs2 <2d, clamp, linear, mipnone>\n" +
								"sub ft4.x, ft5.x, ft7.x\n" +
								"max ft4.x, ft4.x, fc0.y\n";

			var registers : Array = [
				"fc21.xy", "fc21.zw",
				"fc22.xy", "fc22.zw",
				"fc23.xy", "fc23.zw",
				"fc24.xy", "fc24.zw",
				"fc25.xy", "fc25.zw",
				"fc26.xy", "fc26.zw",
				"fc27.xy", "fc27.zw"
			];

			for (var i : int = 1; i < numSamples; ++i) {
				code += "add ft5.xy, v0.xy, " + registers[i] + "\n" +
						"tex ft5, ft5.xyxy, fs2 <2d, clamp, linear, mipnone>\n" +
						"mul ft4.y, ft5.x, ft0.x\n" +
						"mul ft4.z, ft5.y, ft0.y\n" +
						"add ft4.y, ft4.y, ft4.z\n" +
						"min ft4.y, ft4.y, fc0.y\n" +
						"sub ft4.x, ft4.x, ft4.y\n";
			}

			code += "mul ft4.x, ft4.x, fc20.w\n" +
					"sub ft4.x, fc0.z, ft4.x\n";

			return code;
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
		}

		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 20, _fragmentShaderData, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 21, _poissonData, Math.ceil(numSamples/2));
		}
	}
}
