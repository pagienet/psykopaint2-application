package net.psykosoft.psykopaint2.app.view.starling.painting.canvas
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.CanvasView;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class CanvasViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:CanvasView;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var notifyPaintModuleActivatedSignal:NotifyPaintModuleActivatedSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		public function CanvasViewMediator() {
			super();
		}

		override public function initialize():void {

			// Init.
			view.renderedCanvasContainer = renderer.outputSprite;
			// preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );

			super.initialize();
		}

		private function onApplicationStateChanged( newState:StateVO ):void {

			var viewIsActive:Boolean = newState.name == ( StateType.PAINTING_SELECT_STYLE || StateType.PAINTING_EDIT_STYLE );

			if( viewIsActive ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}
	}
}
