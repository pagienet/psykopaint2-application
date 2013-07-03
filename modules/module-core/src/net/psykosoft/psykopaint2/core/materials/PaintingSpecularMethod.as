package net.psykosoft.psykopaint2.core.materials
{
	import away3d.arcane;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.MethodVO;

	use namespace arcane;

	public class PaintingSpecularMethod extends BasicSpecularMethod
	{
		public function PaintingSpecularMethod()
		{
		}

		/**
		 * @inheritDoc
		 */
		override arcane function getFragmentCodePerLight(vo : MethodVO, lightDirReg : ShaderRegisterElement, lightColReg : ShaderRegisterElement, regCache : ShaderRegisterCache) : String
		{
			var code : String = "";
			var t : ShaderRegisterElement;

			if (_isFirstLight)
				t = _totalLightColorReg;
			else {
				t = regCache.getFreeFragmentVectorTemp();
				regCache.addFragmentTempUsages(t, 1);
			}

			var viewDirReg : ShaderRegisterElement = _sharedRegisters.viewDirFragment;
			var normalReg : ShaderRegisterElement  = _sharedRegisters.normalFragment;

			// blinn-phong half vector model
			code += "add " + t + ", " + lightDirReg + ", " + viewDirReg + "\n" +
					"nrm " + t + ".xyz, " + t + "\n" +
					"dp3 " + t + ".w, " + normalReg + ", " + t + "\n" +
					"sat " + t + ".w, " + t + ".w\n";


			if (_useTexture) {
				// apply gloss modulation from texture
				code += "mul " + _specularTexData + ".x, " + _specularTexData + ".w, " + _specularDataRegister + ".w\n" +
						"pow " + t + ".w, " + t + ".w, " + _specularTexData + ".x\n";
			}
			else
				code += "pow " + t + ".w, " + t + ".w, " + _specularDataRegister + ".w\n";

			// attenuate
			if (vo.useLightFallOff)
				code += "mul " + t + ".w, " + t + ".w, " + lightDirReg + ".w\n";

			if (_modulateMethod != null) code += _modulateMethod(vo, t, regCache, _sharedRegisters);

			code += "mul " + t + ".xyz, " + lightColReg + ", " + t + ".w\n";

			if (!_isFirstLight) {
				code += "add " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ", " + t + "\n";
				regCache.removeFragmentTempUsage(t);
			}

			_isFirstLight = false;

			return code;
		}

		/**
		 * @inheritDoc
		 */
		override arcane function getFragmentPostLightingCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			var code : String = "";

			if (vo.numLights == 0)
				return code;

			if (_shadowRegister)
				code += "mul " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ", " + _shadowRegister + ".w\n";

			if (_useTexture) {
				// apply strength modulation from texture
				code += "mul " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ", " + _specularTexData + ".z\n";
				regCache.removeFragmentTempUsage(_specularTexData);
			}

			// apply material's specular reflection
			code += "mul " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ", " + _specularDataRegister + "\n" +
					"add " + targetReg + ".xyz, " + targetReg + ", " + _totalLightColorReg + "\n";
			regCache.removeFragmentTempUsage(_totalLightColorReg);

			return code;
		}
	}
}
