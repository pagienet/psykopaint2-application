package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.app.model.state.data.States;
	import net.psykosoft.psykopaint2.app.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyCameraFlipSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class CaptureImageSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:CaptureImageSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyCameraFlipSignal:NotifyCameraFlipSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

			super.initialize();
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case CaptureImageSubNavigationView.BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_IMAGE ) );
					break;
				case CaptureImageSubNavigationView.BUTTON_LABEL_SHOOT:
					notifyPopUpDisplaySignal.dispatch( PopUpType.CONFIRM_CAPTURE_IMAGE );
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_CONFIRM_CAPTURE_IMAGE ) );
					// TODO: do the actual capture and pass it along to the confirm view
					break;
				case CaptureImageSubNavigationView.BUTTON_LABEL_FLIP:
					notifyCameraFlipSignal.dispatch();
					break;
			}
		}
	}
}
