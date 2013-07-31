package net.psykosoft.psykopaint2.core.drawing.modules
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;

	import net.psykosoft.psykopaint2.core.drawing.smeartools.SmearTool;
	import net.psykosoft.psykopaint2.core.model.RubberMeshModel;
	import net.psykosoft.psykopaint2.core.rendering.RubberMeshRenderer;
	
	public class SmearModule implements IModule
	{
		[Inject]
		public var renderer : RubberMeshRenderer;

		[Inject]
		public var rubberMeshModel : RubberMeshModel;

//		[Inject]
//		public var rubberMeshHistory :  RubberMeshHistoryModel;

		
		
		// TODO: commented by li, we don't use starling anymore
		/*private var _view : DisplayObject;*/

		private var _activeTool : SmearTool;
		private var _active : Boolean;

		public function SmearModule()
		{
			super();
			_activeTool = new SmearTool();
		}

		public function type():String {
			return ModuleType.SMEAR;
		}

		public function draw(context3d : Context3D) : void
		{
			if (_active)
				_activeTool.draw(context3d);
		}

		// TODO: commented by li, we don't use starling anymore
		/*public function get view() : DisplayObject
		{
			return _view;
		}*/

		// TODO: commented by li, we don't use starling anymore
		/*public function set view(view : DisplayObject) : void
		{
			if (_active)
				deactivateTool();

			_view = view;

			if (_active)
				activateTool();
		}*/

		public function activate(bitmapData : BitmapData) : void
		{
			// todo: get real values somewhere
			rubberMeshModel.init(1024, 1024, 1024, 768);
			renderer.init(this);

			_active = true;

			activateTool();
			rubberMeshModel.sourceBitmapData = bitmapData;
			
		}

		public function deactivate() : void
		{
			_active = false;
			deactivateTool();
			renderer.dispose();
			rubberMeshModel.dispose();
		}

		private function onRender(event : Event) : void
		{
			//requestRubberMeshRenderSignal.dispatch();
		}

		private function onToolComplete(event : Event) : void
		{
			//rubberMeshHistory.addAction(_activeTool.getLastStroke());
		}

		private function activateTool() : void
		{
			// TODO: commented by li, we don't use starling anymore
//			_activeTool.activate(_view, rubberMeshModel);
			_activeTool.addEventListener(Event.COMPLETE, onToolComplete);
			_activeTool.addEventListener(Event.RENDER, onRender);
		}

		private function deactivateTool() : void
		{
			_activeTool.deactivate();
			_activeTool.removeEventListener(Event.COMPLETE, onToolComplete);
			_activeTool.removeEventListener(Event.RENDER, onRender);
		}

		public function render() : void
		{
			renderer.render();
		}

		public function get stateType() : String
		{
			return "";
		}
	}
}