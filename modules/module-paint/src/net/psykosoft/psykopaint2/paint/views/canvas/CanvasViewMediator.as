package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.requests.RequestStateUpdateFromModuleActivationSignal;

	public class CanvasViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasView;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:RequestStateUpdateFromModuleActivationSignal;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.STATE_PAINT );
			registerEnablingState( StateType.STATE_PAINT_SELECT_BRUSH );
			registerEnablingState( StateType.STATE_PAINT_SELECT_SHAPE );
			registerEnablingState( StateType.STATE_PAINT_ADJUST_BRUSH );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// Drawing core to app proxying.
			notifyModuleActivatedSignal.add( onDrawingCoreModuleActivated );

			// From app.
			notifyNavigationToggledSignal.add( onNavigationToggled );

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( navVisible:Boolean ):void {
			if( navVisible ) {
				requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight * .76 ) );
			}
			else {
				requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
			}
		}

		// -----------------------
		// Proxying.
		// -----------------------

		private function onDrawingCoreModuleActivated( vo:ModuleActivationVO ):void {
			requestStateUpdateFromModuleActivationSignal.dispatch( vo );
		}
	}
}