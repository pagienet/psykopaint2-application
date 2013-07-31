package net.psykosoft.psykopaint2.paint.commands
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.controllers.GyroscopeLightController;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;

	public class SetupPaintModuleCommand extends TracingCommand
	{
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
		public var moduleManager : ModuleManager

		[Inject]
		public var paintModule : PaintModule;

		override public function execute() : void
		{
			super.execute();

			lightController.enabled = true;
			canvasModel.createPaintTextures();
			canvasHistoryModel.clearHistory();

			initRenderer();

			moduleManager.setActiveModule(paintModule);
			notifyPaintModuleSetUpSignal.dispatch();
		}

		private function initRenderer() : void
		{
			renderer.init();

			// not sure if this should be here at all
			TweenLite.to(renderer, 1.6, { sourceTextureAlpha: 0.333, ease: Sine.easeIn });
		}
	}
}
