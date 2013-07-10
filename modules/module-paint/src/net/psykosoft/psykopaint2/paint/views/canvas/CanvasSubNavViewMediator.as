package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	public class CanvasSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasSubNavView;

		[Inject]
		public var requestClearCanvasSignal:RequestClearCanvasSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		[Inject]
		public var requestCanvasExportSignal:RequestCanvasExportSignal;

		[Inject]
		public var requestPaintingSaveSignal:RequestPaintingSaveSignal;

		[Inject]
		public var requestZoomToggleSignal:RequestZoomToggleSignal;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestPaintingDeletionSignal:RequestPaintingDeletionSignal;

		private var _incomingState:String;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Remember incoming state for when exiting the paint module.
			_incomingState = stateModel.getLastStateOfCategory( "home" );
			trace( this, "previous home state was: " + _incomingState );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {

				case CanvasSubNavView.LBL_HOME:
				{
					trace( this, "leaving paint mode. Will 1) save, 2) change state to home, 3) request a zoom out on home, 4) deactivate painting" );
					requestPaintingSaveSignal.dispatch( paintingModel.focusedPaintingId, true );
					requestStateChange( StateType.HOME_ON_EASEL );
					requestZoomToggleSignal.dispatch( false );
					break;
				}

				case CanvasSubNavView.LBL_DESTROY:
				{
					if( paintingModel.focusedPaintingId != PaintingInfoVO.DEFAULT_VO_ID && paintingModel.focusedPaintingId != "" ) {
						requestPaintingDeletionSignal.dispatch( paintingModel.focusedPaintingId );
					}
					break;
				}

				case CanvasSubNavView.LBL_CLEAR:
				{
					requestClearCanvasSignal.dispatch();
					break;
				}

				case CanvasSubNavView.LBL_MODEL:
				{
					requestNavigationToggleSignal.dispatch( -1 );
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}

				/*case CanvasSubNavView.LBL_COLOR:
				{
//					requestStateChange( StateType.COLOR_STYLE );
					break;
				}*/

				case CanvasSubNavView.LBL_EXPORT:
				{
					requestCanvasExportSignal.dispatch();
					break;
				}

				case CanvasSubNavView.LBL_SAVE:
				{
					if( paintingModel.focusedPaintingId != "" ) {
						requestPaintingSaveSignal.dispatch( paintingModel.focusedPaintingId, false );
					}
					break;
				}

				/*case CanvasSubNavView.LBL_PUBLISH:
				{
					// TODO: trigger publish process
					break;
				}*/

				case CanvasSubNavView.LBL_PICK_A_BRUSH:
				{
					requestStateChange( StateType.PAINT_SELECT_BRUSH );
					break;
				}
			}
		}
	}
}
