package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpType;

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
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_CAPTURE_IMAGE ) );
					break;
				case ConfirmCaptureSubNavigationView.BUTTON_LABEL_KEEP:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_COLORS ) );
					notifyPopUpRemovalSignal.dispatch();
					// TODO: pass along the image
					break;
			}
		}
	}
}
