package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.utils.getTimer;
	
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingInfoSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSavePaintingToServerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	public class CanvasSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CanvasSubNavView;

		//[Inject]
		//public var requestClearCanvasSignal:RequestClearCanvasSignal;

		[Inject]
		public var requestCanvasExportSignal:RequestCanvasExportSignal;

		[Inject]
		public var requestClosePaintViewSignal:RequestClosePaintViewSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var loggedInUserProxy : LoggedInUserProxy;
		
		[Inject]
		public var userPaintSettingModel:UserPaintSettingsModel;

		[Inject]
		public var requestSavePaintingToServerSignal : RequestSavePaintingToServerSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingInfoSavedSignal;

		[Inject]
		public var requestPaintingSaveSignal:RequestPaintingSaveSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var showPopUpSignal:RequestShowPopUpSignal;

		private var _time:uint;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			view.isContinuedPainting = userPaintSettingModel.isContinuedPainting;
			
		}

		// ---------------------------------------------------------------------
		// From view.
		// ---------------------------------------------------------------------

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case CanvasSubNavView.ID_SAVE:
					requestClosePaintViewSignal.dispatch(true);
					break;

				case CanvasSubNavView.ID_DISCARD:
					requestClosePaintViewSignal.dispatch(false);
					break;

				/*case CanvasSubNavView.ID_CLEAR:
					requestClearCanvasSignal.dispatch();
					break;*/

				case CanvasSubNavView.ID_DOWNLOAD:
					requestCanvasExportSignal.dispatch();
					break;

				case CanvasSubNavView.ID_PUBLISH:
					if (loggedInUserProxy.isLoggedIn()) {
						requestSavePaintingToServerSignal.dispatch();
					}
					else {
						showPopUpSignal.dispatch(PopUpType.LOGIN);
					}
					break;
				case CanvasSubNavView.ID_PICK_A_BRUSH:
					requestNavigationStateChange( NavigationStateType.PAINT_SELECT_BRUSH );
					break;
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
