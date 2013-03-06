package net.psykosoft.psykopaint2.app.view.painting.captureimage
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class ConfirmCaptureSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:ConfirmCaptureSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpRemovalSignal:NotifyPopUpRemovalSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

			super.initialize();
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case ConfirmCaptureSubNavigationView.BUTTON_LABEL_BACK_TO_CAPTURE:
					notifyPopUpDisplaySignal.dispatch( PopUpType.CAPTURE_IMAGE );
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_CAPTURE_IMAGE ) );
					break;
				case ConfirmCaptureSubNavigationView.BUTTON_LABEL_KEEP:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_COLORS ) );
					notifyPopUpRemovalSignal.dispatch();
					// TODO: pass along the image
					break;
			}
		}
	}
}
