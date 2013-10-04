package net.psykosoft.psykopaint2.paint.commands
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import flash.display.BitmapData;

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
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
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.views.base.ViewLayerOrdering;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.views.base.PaintRootView;

	public class SetupPaintModuleCommand extends TracingCommand
	{
		[Inject]
		public var stage:Stage;

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

		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		[Inject]
		public var lightingModel : LightingModel;

		[Inject]
		public var stage3D : Stage3D;

		override public function execute() : void
		{
			super.execute();

			var mode : String = initPaintingVO.sourceImageData? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE;

			addPaintModuleDisplay();

			lightController.enabled = true;

			canvasModel.createPaintTextures();
			brushKitManager.activate(mode);

			importPaintingData();

			canvasHistoryModel.clearHistory();

			renderer.init(mode);

			// not sure if this should be here at all
			if (mode == PaintMode.PHOTO_MODE)
				TweenLite.to(renderer, 1.6, { sourceTextureAlpha: 0.333, ease: Sine.easeIn });

			GpuRenderManager.addRenderingStep(brushKitManager.update, GpuRenderingStepType.PRE_CLEAR);

			// ugly ugly ugly, but we need a frame to process the texture uploads before triggering any more stuff
			waitForNextFrame();
		}

		private function addPaintModuleDisplay():void {
			var paintRootView : PaintRootView = new PaintRootView();
			requestAddViewToMainLayerSignal.dispatch( paintRootView, ViewLayerOrdering.AT_BOTTOM_LAYER );
		}

		private function waitForNextFrame() : void
		{
			stage.addEventListener(Event.ENTER_FRAME, onNextFrame);
		}

		private function onNextFrame(event : Event) : void
		{
			stage.removeEventListener(Event.ENTER_FRAME, onNextFrame);
			notifyPaintModuleSetUpSignal.dispatch();
		}

		private function importPaintingData() : void
		{
			var canvasImporter : CanvasImporter = new CanvasImporter();
			canvasImporter.importPainting(canvasModel, initPaintingVO);
			initPaintingVO.dispose();
		}
	}
}
