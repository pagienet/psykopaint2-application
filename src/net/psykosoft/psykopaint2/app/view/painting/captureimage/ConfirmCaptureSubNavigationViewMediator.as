package net.psykosoft.psykopaint2.app.view.painting.captureimage
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class ConfirmCaptureSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:ConfirmCaptureSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpRemovalSignal:NotifyPopUpRemovalSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case ConfirmCaptureSubNavigationView.BUTTON_LABEL_BACK_TO_CAPTURE:
					notifyPopUpDisplaySignal.dispatch( PopUpType.CAPTURE_IMAGE );
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_CAPTURE_IMAGE ) );
					break;
				case ConfirmCaptureSubNavigationView.BUTTON_LABEL_KEEP:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_COLORS ) );
					notifyPopUpRemovalSignal.dispatch();
					// TODO: pass along the image
					break;
			}
		}
	}
}
