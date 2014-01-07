package away3d.hacks
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;

	use namespace arcane;

	// WARNING: Incompatible with blending and depth comparison modes!
	public class MaskingMethod extends EffectMethodBase
	{
		private var _writeRed : Boolean = true;
		private var _writeGreen : Boolean = true;
		private var _writeBlue : Boolean = true;
		private var _writeAlpha : Boolean = true;
		private var _writeDepth : Boolean = true;

		public function MaskingMethod()
		{
		}


		public function get writeRed():Boolean
		{
			return _writeRed;
		}

		public function set writeRed(value:Boolean):void
		{
			_writeRed = value;
		}

		public function get writeGreen():Boolean
		{
			return _writeGreen;
		}

		public function set writeGreen(value:Boolean):void
		{
			_writeGreen = value;
		}

		public function get writeBlue():Boolean
		{
			return _writeBlue;
		}

		public function set writeBlue(value:Boolean):void
		{
			_writeBlue = value;
		}

		public function get writeAlpha():Boolean
		{
			return _writeAlpha;
		}

		public function set writeAlpha(value:Boolean):void
		{
			_writeAlpha = value;
		}

		public function get writeDepth():Boolean
		{
			return _writeDepth;
		}

		public function set writeDepth(value:Boolean):void
		{
			_writeDepth = value;
		}

		public function disableAll():void
		{
			_writeRed = false;
			_writeGreen = false;
			_writeBlue = false;
			_writeAlpha = false;
			_writeDepth = false;
		}

		override arcane function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			return "";
		}

		override arcane function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			stage3DProxy._context3D.setColorMask(_writeRed, _writeGreen, _writeBlue, _writeAlpha);
			stage3DProxy._context3D.setDepthTest(_writeDepth, Context3DCompareMode.LESS);
		}


		override arcane function deactivate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			stage3DProxy._context3D.setColorMask(true, true, true, true);
			stage3DProxy._context3D.setDepthTest(true, Context3DCompareMode.LESS);
		}
	}
}
