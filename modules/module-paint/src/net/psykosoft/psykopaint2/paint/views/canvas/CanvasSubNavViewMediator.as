package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSavePaintingToServerSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingDeletionSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	public class CanvasSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CanvasSubNavView;

		[Inject]
		public var requestClearCanvasSignal:RequestClearCanvasSignal;

		[Inject]
		public var requestCanvasExportSignal:RequestCanvasExportSignal;

		[Inject]
		public var requestClosePaintViewSignal:RequestClosePaintViewSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestPaintingDeletionSignal:RequestPaintingDeletionSignal;

		[Inject]
		public var requestSavePaintingToServerSignal : RequestSavePaintingToServerSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingInfoSavedSignal;

		[Inject]
		public var requestPaintingSaveSignal:RequestPaintingSaveSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		private var _time:uint;

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
					requestClosePaintViewSignal.dispatch( true);
					break;
				}

				case CanvasSubNavView.ID_DISCARD:
				{
					/*
					if( paintingModel.activePaintingId != PaintingInfoVO.DEFAULT_VO_ID && paintingModel.activePaintingId != "" ) {
						requestPaintingDeletionSignal.dispatch( paintingModel.activePaintingId );
					}
					*/
					requestClosePaintViewSignal.dispatch( false);
					break;
				}
/*
				case CanvasSubNavView.ID_CLEAR:
				{
					requestClearCanvasSignal.dispatch();
					break;
				}
					*/

				case CanvasSubNavView.ID_EXPORT:
				{
					requestCanvasExportSignal.dispatch();
					break;
				}

				case CanvasSubNavView.ID_PUBLISH:
				{
					requestSavePaintingToServerSignal.dispatch();
					break;
				}
/*
				case CanvasSubNavView.ID_SAVE:
				{
					_time = getTimer();
					ConsoleView.instance.log( this, "saving..." );
					ConsoleView.instance.logMemory();

					notifyPaintingSavedSignal.addOnce( onPaintingSaved );
					requestPaintingSaveSignal.dispatch();
					break;
				}
*/
				case CanvasSubNavView.ID_PICK_A_BRUSH:
				{
					requestNavigationStateChange( NavigationStateType.PAINT_SELECT_BRUSH );
					break;
				}
			}
		}

		private function onPaintingSaved( success:Boolean ):void {

			_time = getTimer() - _time;
			ConsoleView.instance.log( this, "onPaintingSaved() - saving took: " + _time + "ms" );
			ConsoleView.instance.logMemory();

			requestHidePopUpSignal.dispatch();
		}
	}
}
