package net.psykosoft.psykopaint2.app.view.settings
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class SettingsSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SettingsSubNavigationView;

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
			trace( this, "button pressed: " + buttonLabel);
			switch( buttonLabel ) {
				case SettingsSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
					break;
				case SettingsSubNavigationView.BUTTON_LABEL_WALLPAPER:
					requestStateChange( new StateVO( ApplicationStateType.SETTINGS_WALLPAPER ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE );
					break;
			}
		}
	}
}
