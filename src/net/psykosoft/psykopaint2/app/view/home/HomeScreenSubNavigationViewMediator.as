package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class HomeScreenSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:HomeScreenSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case HomeScreenSubNavigationView.BUTTON_LABEL_SETTINGS:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.SETTINGS ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_GALLERY:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PAINTING ) );
					break;
			}
		}
	}
}
