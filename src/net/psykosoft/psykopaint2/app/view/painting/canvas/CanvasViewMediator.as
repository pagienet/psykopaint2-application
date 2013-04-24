package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;

	public class CanvasViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var canvasView:CanvasView;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var notifyPaintModuleActivatedSignal:NotifyPaintModuleActivatedSignal;

		public function CanvasViewMediator() {
			super();
		}

		override public function initialize():void {

			super.initialize();
			registerView( canvasView );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_BRUSH );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_STYLE );

			// Init.
			canvasView.renderedCanvasContainer = renderer.outputSprite;
			// preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = canvasView;
		}
	}
}
