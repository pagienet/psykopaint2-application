package net.psykosoft.psykopaint2.paint.views.canvas
{
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;

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
		public var requestClosePaintViewSignal:RequestClosePaintViewSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestPaintingDeletionSignal:RequestPaintingDeletionSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
		}

		// ---------------------------------------------------------------------
		// From view.
		// ---------------------------------------------------------------------

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case CanvasSubNavView.ID_HOME:
				{
					requestClosePaintViewSignal.dispatch();

					break;
				}

				case CanvasSubNavView.ID_DESTROY:
				{
					if( paintingModel.activePaintingId != PaintingInfoVO.DEFAULT_VO_ID && paintingModel.activePaintingId != "" ) {
						requestPaintingDeletionSignal.dispatch( paintingModel.activePaintingId );
					}
					break;
				}

				case CanvasSubNavView.ID_CLEAR:
				{
					requestClearCanvasSignal.dispatch();
					break;
				}

				/*case CanvasSubNavView.ID_MODEL:
				 {
				 requestNavigationToggleSignal.dispatch( -1, 0.5 );
				 requestStateChange( StateType.PICK_IMAGE );
				 break;
				 }*/

				/*case CanvasSubNavView.ID_COLOR:
				 {
				 //					requestStateChange( StateType.COLOR_STYLE );
				 break;
				 }*/

				case CanvasSubNavView.ID_EXPORT:
				{
					requestCanvasExportSignal.dispatch();
					break;
				}

				/*case CanvasSubNavView.ID_SAVE:
				 {
				 requestPaintingSaveSignal.dispatch( paintingModel.focusedPaintingId, false );
				 break;
				 }*/

				/*case CanvasSubNavView.ID_PUBLISH:
				 {
				 // TODO: trigger publish process
				 break;
				 }*/

				case CanvasSubNavView.ID_PICK_A_BRUSH:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PAINT_SELECT_BRUSH );
					break;
				}
			}
		}
	}
}
