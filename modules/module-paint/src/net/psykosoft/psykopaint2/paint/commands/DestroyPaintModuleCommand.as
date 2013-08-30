package net.psykosoft.psykopaint2.paint.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationDisposalSignal;
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
		public var requestNavigationDisposalSignal:RequestNavigationDisposalSignal;

		[Inject]
		public var requestPaintRootViewRemovalSignal:RequestPaintRootViewRemovalSignal;

		override public function execute() : void
		{
			super.execute();
			lightController.enabled = false;
			canvasModel.disposePaintTextures();
			canvasHistoryModel.clearHistory();	// cleans up snapshot memory too
			canvasRenderer.dispose();
			brushKitManager.deactivate();
			GpuRenderManager.removeRenderingStep(brushKitManager.update, GpuRenderingStepType.PRE_CLEAR);
			BrushKit.dispose();
			
			removePaintModuleDisplay();

			notifyPaintModuleDestroyedSignal.dispatch();
		}

		private function removePaintModuleDisplay():void {

			// Dispose all sub-navigation instances currently cached in SbNavigationView.
			requestNavigationDisposalSignal.dispatch();

			// Dispose home root view.
			requestPaintRootViewRemovalSignal.dispatch();
		}
	}
}
