package net.psykosoft.psykopaint2.core.materials
{
	import away3d.arcane;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.MethodVO;

	use namespace arcane;

	public class PaintingNormalMethod extends BasicNormalMethod
	{
		private var _bumpiness : Number;

		public function PaintingNormalMethod(bumpiness : Number = 20)
		{
			_bumpiness = bumpiness;
		}


		override arcane function initConstants(vo : MethodVO) : void
		{
			vo.fragmentData[vo.fragmentConstantsIndex] = _bumpiness;
		}

		override arcane function get tangentSpace() : Boolean
		{
			return true;
		}

		override arcane function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			var bumpiness : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			_normalTextureRegister = regCache.getFreeTextureReg();
			vo.texturesIndex = _normalTextureRegister.index;
			vo.fragmentConstantsIndex = bumpiness.index * 4;

			return 	getTex2DSampleCode(vo,  targetReg, _normalTextureRegister, normalMap) +
					"sub " + targetReg + ".xy, " + targetReg + ".xy, " + _sharedRegisters.commons + ".x	\n" +
					"mul " + targetReg + ".xy, " + targetReg + ".xy, " + bumpiness + ".x\n" +
					"mov " + targetReg + ".z, " + _sharedRegisters.commons + ".w\n" +
					"nrm " + targetReg + ".xyz, " + targetReg + ".xyz\n";
		}
	}
}
