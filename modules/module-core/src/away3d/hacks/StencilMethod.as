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

	public class StencilMethod extends EffectMethodBase
	{
		private var _referenceValue:uint;
		private var _triangleFace:String = Context3DTriangleFace.FRONT_AND_BACK;
		private var _compareMode:String = Context3DCompareMode.ALWAYS;
		private var _actionDepthAndStencilPass : String = Context3DStencilAction.KEEP;
		private var _actionDepthFail : String = Context3DStencilAction.KEEP;
		private var _actionDepthPassStencilFail : String = Context3DStencilAction.KEEP;

		public function StencilMethod()
		{
		}

		public function get referenceValue():uint
		{
			return _referenceValue;
		}

		public function set referenceValue(value:uint):void
		{
			_referenceValue = value;
		}

		public function get triangleFace():String
		{
			return _triangleFace;
		}

		public function set triangleFace(value:String):void
		{
			_triangleFace = value;
		}

		public function get compareMode():String
		{
			return _compareMode;
		}

		public function set compareMode(value:String):void
		{
			_compareMode = value;
		}

		public function get actionDepthAndStencilPass():String
		{
			return _actionDepthAndStencilPass;
		}

		public function set actionDepthAndStencilPass(value:String):void
		{
			_actionDepthAndStencilPass = value;
		}

		public function get actionDepthFail():String
		{
			return _actionDepthFail;
		}

		public function set actionDepthFail(value:String):void
		{
			_actionDepthFail = value;
		}

		public function get actionDepthPassStencilFail():String
		{
			return _actionDepthPassStencilFail;
		}

		public function set actionDepthPassStencilFail(value:String):void
		{
			_actionDepthPassStencilFail = value;
		}

		override arcane function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			return "";
		}

		override arcane function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			var context : Context3D = stage3DProxy._context3D;
			context.setStencilActions(_triangleFace, _compareMode, _actionDepthAndStencilPass, _actionDepthFail, _actionDepthPassStencilFail);
			context.setStencilReferenceValue(_referenceValue);
		}


		override arcane function deactivate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			stage3DProxy._context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		}
	}
}
