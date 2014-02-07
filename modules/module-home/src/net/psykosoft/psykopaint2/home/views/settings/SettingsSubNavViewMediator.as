package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
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

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From app.
			loggedInUserProxy.onChange.add( onLoggedInUserChange );
		}

		override protected function onViewSetup():void
		{
			super.onViewSetup();
			view.setLoginBtn( loggedInUserProxy.isLoggedIn() ? SettingsSubNavView.ID_LOGOUT : SettingsSubNavView.ID_LOGIN );
		}

		override public function destroy():void {
			super.destroy();
			loggedInUserProxy.onChange.remove( onLoggedInUserChange );
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
					trace( this, "login clicked" );
					if( loggedInUserProxy.isLoggedIn() ) {
						view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, false );
						trace( this, "logging out" );
						// no need to check for success, is implicit in onChange
						loggedInUserProxy.logOut(null, onLogOutFailed);
					}
					else {
						trace( this, "logging in" );
						requestShowPopUpSignal.dispatch( PopUpType.LOGIN );
					}
					break;
				}
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onLogOutFailed( amfErrorCode:int, reason:String ):void {
			trace( this, "log out failed - error code: " + amfErrorCode );
		}

		private function onLoggedInUserChange():void {
			if (loggedInUserProxy.isLoggedIn()) {
				view.setLoginBtn(SettingsSubNavView.ID_LOGOUT);
			}
			else {
				view.setLoginBtn(SettingsSubNavView.ID_LOGIN);
			}
			view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, true );
		}
	}
}
