package net.psykosoft.psykopaint2.view.starling.popups
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.starling.popups.noplatform.FeatureNotInPlatformPopUpView;
	import net.psykosoft.psykopaint2.view.starling.popups.nofeature.FeatureNotImplementedPopUpView;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class PopUpManagerViewMediator extends StarlingMediator
	{
		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var view:PopUpManagerView;

		override public function initialize():void {

			// From app.
			notifyStateChangedSignal.add( onStateChange );

			// From view.
			view.popUpClosedSignal.add( onPopUpClosed );

			super.initialize();
		}

		private function onPopUpClosed():void {
			requestStateChangeSignal.dispatch( new StateVO( States.PREVIOUS_STATE ) );
		}

		private function onStateChange( state:StateVO ):void {
			switch( state.name ) {
				case States.FEATURE_NOT_IMPLEMENTED:
					view.showPopUp( FeatureNotImplementedPopUpView );
					break;
				case States.FEATURE_NOT_AVAILABLE_ON_THIS_PLATFORM:
					view.showPopUp( FeatureNotInPlatformPopUpView );
					break;
				default:
					view.hideLastPopUp();
					break
			}
		}
	}
}
