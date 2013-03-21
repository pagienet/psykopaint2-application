package net.psykosoft.psykopaint2.app.view.settings
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SettingsSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SettingsSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

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
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
					break;
				case SettingsSubNavigationView.BUTTON_LABEL_WALLPAPER:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.SETTINGS_WALLPAPER ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE );
					break;
			}
		}
	}
}
