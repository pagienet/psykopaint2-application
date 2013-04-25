package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class HomeScreenSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:HomeScreenSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEWS1:
//					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) ); // TODO: currently disabled
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEWS2:
//					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO: currently disabled
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEWS3:
//					requestStateChange( new StateVO( ApplicationStateType.PAINTING ) ); // TODO: currently disabled
					break;
			}
		}
	}
}
