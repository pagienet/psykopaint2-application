package net.psykosoft.psykopaint2.paint.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;

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

		override public function execute() : void
		{
			super.execute();
			lightController.enabled = false;
			canvasModel.disposePaintTextures();
			canvasHistoryModel.clearHistory();	// cleans up snapshot memory too
			canvasRenderer.disposeBackground();
			brushKitManager.deactivate();
			GpuRenderManager.removeRenderingStep(brushKitManager.update, GpuRenderingStepType.PRE_CLEAR);

			notifyPaintModuleDestroyedSignal.dispatch();
		}
	}
}
