package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	public class CanvasSubNavViewMediator extends SubNavigationMediatorBase
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
		public var stateModel:StateModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestPaintingDeletionSignal:RequestPaintingDeletionSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		private var _incomingState:String;
		private var _waitingForSaveToContinueToHomeState:Boolean;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From app.
			notifyPaintingSavedSignal.add( onPaintingSaved );

			// Remember incoming state for when exiting the paint module.
			_incomingState = stateModel.getLastStateOfCategory( "home" );
			trace( this, "previous home state was: " + _incomingState );
		}

		// ---------------------------------------------------------------------
		// From view.
		// ---------------------------------------------------------------------

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {

				case CanvasSubNavView.LBL_HOME:
				{
					_waitingForSaveToContinueToHomeState = true;

					// Pick one below to enable/disable auto save when leaving home mode.
					requestPaintingSaveSignal.dispatch( paintingModel.activePaintingId, true );
//					onPaintingSaved();

					break;
				}

				case CanvasSubNavView.LBL_DESTROY:
				{
					if( paintingModel.activePaintingId != PaintingInfoVO.DEFAULT_VO_ID && paintingModel.activePaintingId != "" ) {
						requestPaintingDeletionSignal.dispatch( paintingModel.activePaintingId );
					}
					break;
				}

				case CanvasSubNavView.LBL_CLEAR:
				{
					requestClearCanvasSignal.dispatch();
					break;
				}

				/*case CanvasSubNavView.LBL_MODEL:
				{
					requestNavigationToggleSignal.dispatch( -1, 0.5 );
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}*/

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

				/*case CanvasSubNavView.LBL_SAVE:
				{
					requestPaintingSaveSignal.dispatch( paintingModel.focusedPaintingId, false );
					break;
				}*/

				/*case CanvasSubNavView.LBL_PUBLISH:
				{
					// TODO: trigger publish process
					break;
				}*/

				case CanvasSubNavView.LBL_PICK_A_BRUSH:
				{
					requestStateChange__OLD_TO_REMOVE( StateType.PAINT_SELECT_BRUSH );
					break;
				}
			}
		}

		// ---------------------------------------------------------------------
		// From app.
		// ---------------------------------------------------------------------

		private function onPaintingSaved():void {
			if( _waitingForSaveToContinueToHomeState ) {
				setTimeout( function():void {
					requestStateChange__OLD_TO_REMOVE( StateType.TRANSITION_TO_HOME_MODE );
				}, 100 );
				_waitingForSaveToContinueToHomeState = false;
			}
		}
	}
}
