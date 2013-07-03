package net.psykosoft.psykopaint2.core.materials
{
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.MethodVO;

	public class PaintingDiffuseMethod extends BasicDiffuseMethod
	{
		public function PaintingDiffuseMethod()
		{
			super();
		}

		override protected function sampleTexture(vo : MethodVO, albedo : ShaderRegisterElement) : String
		{
			var code : String = getTex2DSampleCode(vo, albedo, _diffuseInputRegister, texture);
			code += "sub " + albedo + ".w, "  + _sharedRegisters.commons + ".w, " + albedo + ".w\n" +
					"add " + albedo + ", " + albedo + ", " + albedo + ".w\n";
			return code;
		}
	}
}
