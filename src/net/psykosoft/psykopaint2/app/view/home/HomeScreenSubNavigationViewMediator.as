package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
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
				case HomeScreenSubNavigationView.BUTTON_LABEL_SETTINGS:
					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_GALLERY:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE );
					break;
				case HomeScreenSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING ) );
					break;
			}
		}
	}
}
