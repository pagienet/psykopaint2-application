package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestStateUpdateFromModuleActivationSignal;

	public class PtCanvasViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtCanvasView;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:PtRequestStateUpdateFromModuleActivationSignal;

		[Inject]
		public var notifyNavigationToggledSignal:CrNotifyNavigationToggledSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( CrStateType.STATE_PAINT );
			registerEnablingState( CrStateType.STATE_PAINT_SELECT_BRUSH );
			registerEnablingState( CrStateType.STATE_PAINT_SELECT_SHAPE );
			registerEnablingState( CrStateType.STATE_PAINT_ADJUST_BRUSH );

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
