package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.drawing.actions.IRubberMeshAction;
	import net.psykosoft.psykopaint2.core.drawing.modules.SmearModule;
	import net.psykosoft.psykopaint2.core.model.RubberMeshHistoryModel;
	import net.psykosoft.psykopaint2.core.model.RubberMeshModel;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class RubberMeshRenderer
	{
		[Inject]
		public var rubberMesh : RubberMeshModel;

//		[Inject]
//		public var rubberMeshHistory : RubberMeshHistoryModel;

		[Inject]
		public var stage3D : Stage3D;

		private var _smearModule : SmearModule;

		private var _context3D : Context3D;
		private var _renderNeeded : Boolean;

		public function RubberMeshRenderer()
		{
		//	_actionsToBake = new Vector.<IRubberMeshAction>();
		}

		/*
		public function bakeAction(action : IRubberMeshAction) : void
		{
			_actionsToBake.push(action);
			render();
		}
		*/

		public function init(module : SmearModule) : void
		{
			_renderNeeded = true;
			_smearModule = module;
		}

		
		public function render() : void
		{
			if (_renderNeeded) {
				_context3D = stage3D.context3D;
				_context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);

				_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

				_smearModule.draw(_context3D);

				_context3D.setVertexBufferAt(0, null);
				_context3D.setVertexBufferAt(1, null);
				_context3D.setRenderToBackBuffer();
				_renderNeeded = false;
			}
		}

		public function dispose() : void
		{
		}

		public function markForRender() : void
		{
			_renderNeeded = true;
		}
	}
}
