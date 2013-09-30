package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class SettingsSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SettingsSubNavView;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var loggedInUserProxy:LoggedInUserProxy;

		[Inject]
		public var notifyUserLoggedInSignal:NotifyUserLoggedInSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From app.
			notifyUserLoggedInSignal.add( onUserLoggedIn );

			// Login button.
			view.setLoginBtn( loggedInUserProxy.isLoggedIn() ? SettingsSubNavView.ID_LOGOUT : SettingsSubNavView.ID_LOGIN );
		}

		// -----------------------
		// From view.
		// -----------------------

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case SettingsSubNavView.ID_WALLPAPER: {
					requestNavigationStateChange( NavigationStateType.SETTINGS_WALLPAPER );
					break;
				}

				case SettingsSubNavView.ID_LOGIN: {
					if( loggedInUserProxy.isLoggedIn() ) {
						// TODO: request log out and dispatch message...
					}
					else {
						requestShowPopUpSignal.dispatch( PopUpType.LOGIN );
					}
					break;
				}
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onUserLoggedIn():void {
			view.relabelButtonWithId( SettingsSubNavView.ID_LOGIN, SettingsSubNavView.ID_LOGOUT );
		}
	}
}
