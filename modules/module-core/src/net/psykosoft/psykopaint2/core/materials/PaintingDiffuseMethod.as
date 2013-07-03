package net.psykosoft.psykopaint2.core.materials
{
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.MethodVO;

	public class PaintingDiffuseMethod extends BasicDiffuseMethod
	{
		public function PaintingDiffuseMethod()
		{
			super();
		}

		override protected function sampleTexture(vo : MethodVO, regCache : ShaderRegisterCache, target : ShaderRegisterElement) : String
		{
			var code : String = getTex2DSampleCode(vo, target, _diffuseInputRegister, texture);
			var temp : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			code += "sub " + temp + ".w, "  + _sharedRegisters.commons + ".w, " + target + ".w\n" +
					"add " + target + ", " + target + ", " + temp + ".w\n";

			return code;
		}
	}
}
