package net.psykosoft.psykopaint2.app.view.painting.captureimage
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyCameraFlipSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class CaptureImageSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:CaptureImageSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyCameraFlipSignal:NotifyCameraFlipSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case CaptureImageSubNavigationView.BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_IMAGE ) );
					break;
				case CaptureImageSubNavigationView.BUTTON_LABEL_SHOOT:
					notifyPopUpDisplaySignal.dispatch( PopUpType.CONFIRM_CAPTURE_IMAGE );
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_CONFIRM_CAPTURE_IMAGE ) );
					// TODO: do the actual capture and pass it along to the confirm view
					break;
				case CaptureImageSubNavigationView.BUTTON_LABEL_FLIP:
					notifyCameraFlipSignal.dispatch();
					break;
			}
		}
	}
}
