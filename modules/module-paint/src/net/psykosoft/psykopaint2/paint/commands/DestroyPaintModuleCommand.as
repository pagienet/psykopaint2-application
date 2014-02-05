package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display3D.textures.Texture;
	
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.intrinsics.MemoryManagerIntrinsics;
	import net.psykosoft.psykopaint2.core.managers.assets.ShakeAndBakeManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintRootViewRemovalSignal;
	
	public class DestroyPaintModuleCommand extends TracingCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		[Inject]
		public var notifyPaintModuleDestroyedSignal : NotifyPaintModuleDestroyedSignal;

		[Inject]
		public var lightController:GyroscopeLightController;

		[Inject]
		public var brushKitManager : BrushKitManager;

		[Inject]
		public var requestPaintRootViewRemovalSignal:RequestPaintRootViewRemovalSignal;

		[Inject]
		public var lightingModel:LightingModel;

		[Inject]
		public var shaker:ShakeAndBakeManager;

		override public function execute() : void
		{
			super.execute();
			//Not required - already done before
			//MemoryManagerIntrinsics.releaseAllMemory();
			lightController.enabled = false;
			canvasModel.dispose();
			canvasHistoryModel.clearHistory();	// cleans up snapshot memory too
			canvasRenderer.dispose();
			if (lightingModel.environmentMap) {
				var map : Texture = lightingModel.environmentMap;
				lightingModel.environmentMap = null;
				map.dispose();
			}
			brushKitManager.deactivate();
			GpuRenderManager.removeRenderingStep(brushKitManager.update, GpuRenderingStepType.PRE_CLEAR);
			BrushKit.dispose();

			removePaintModuleDisplay();

			notifyPaintModuleDestroyedSignal.dispatch();
		}

		private function removePaintModuleDisplay():void 
		{
			// Dispose home root view.
			requestPaintRootViewRemovalSignal.dispatch();
			// Flush assets.
			shaker.disconnect( ShakeAndBakeManager.PAINT_CONNECTOR_URL );
		}
	}
}
