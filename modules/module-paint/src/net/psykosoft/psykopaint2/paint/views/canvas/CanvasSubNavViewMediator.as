package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestGoToHomeWithCanvasSnapshotSignal;
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
		public var requestGoToHomeWithCanvasSnapshotSignal:RequestGoToHomeWithCanvasSnapshotSignal;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var paintingModel:PaintingModel;

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

				case CanvasSubNavView.LBL_HOME: {
					requestGoToHomeWithCanvasSnapshotSignal.dispatch( _incomingState );
					break;
				}

				case CanvasSubNavView.LBL_DESTROY: {
					// TODO: trigger delete process
					break;
				}
				case CanvasSubNavView.LBL_CLEAR: {
					requestClearCanvasSignal.dispatch();
					break;
				}
				case CanvasSubNavView.LBL_MODEL: {
					requestNavigationToggleSignal.dispatch( -1 );
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}
				case CanvasSubNavView.LBL_COLOR: {
					requestStateChange( StateType.COLOR_STYLE );
					break;
				}
				case CanvasSubNavView.LBL_EXPORT: {
					requestCanvasExportSignal.dispatch();
					break;
				}
				case CanvasSubNavView.LBL_SAVE: {
					requestPaintingSaveSignal.dispatch( paintingModel.focusedPaintingId );
					break;
				}
				case CanvasSubNavView.LBL_PUBLISH: {
					// TODO: trigger publish process
					break;
				}

				case CanvasSubNavView.LBL_PICK_A_BRUSH: {
					requestStateChange( StateType.PAINT_SELECT_BRUSH );
					break;
				}
			}
		}
	}
}
