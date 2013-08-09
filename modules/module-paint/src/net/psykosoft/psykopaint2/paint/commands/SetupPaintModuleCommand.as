package net.psykosoft.psykopaint2.paint.commands
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.io.CanvasImporter;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;

	public class SetupPaintModuleCommand extends TracingCommand
	{
		[Inject]
		public var initPaintingVO : PaintingDataVO;

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var renderer : CanvasRenderer;

		[Inject]
		public var notifyPaintModuleSetUpSignal : NotifyPaintModuleSetUpSignal;

		[Inject]
		public var lightController:GyroscopeLightController;

		[Inject]
		public var brushKitManager : BrushKitManager;

		override public function execute() : void
		{
			super.execute();

			lightController.enabled = true;

			canvasModel.createPaintTextures();
			brushKitManager.activate();

			if (initPaintingVO)
				importPaintingData();

			canvasHistoryModel.clearHistory();

			initRenderer();

			GpuRenderManager.addRenderingStep(brushKitManager.update, GpuRenderingStepType.PRE_CLEAR);

			// ugly ugly ugly, but we need a frame to process the texture uploads before triggering any more stuff
			waitForNextFrame();
		}

		private function waitForNextFrame() : void
		{
			var sprite : Sprite = new Sprite();
			sprite.addEventListener(Event.ENTER_FRAME, onNextFrame);
		}

		private function onNextFrame(event : Event) : void
		{
			event.target.removeEventListener(Event.ENTER_FRAME, onNextFrame);
			notifyPaintModuleSetUpSignal.dispatch();
		}

		private function importPaintingData() : void
		{
			var canvasImporter : CanvasImporter = new CanvasImporter();
			canvasImporter.importPainting(canvasModel, initPaintingVO);
			initPaintingVO.dispose();
		}

		private function initRenderer() : void
		{
			renderer.init();

			// not sure if this should be here at all
			TweenLite.to(renderer, 1.6, { sourceTextureAlpha: 0.333, ease: Sine.easeIn });
		}
	}
}
