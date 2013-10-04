package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogOutFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedOutSignal;
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

		[Inject]
		public var notifyUserLoggedOutSignal:NotifyUserLoggedOutSignal;

		[Inject]
		public var notifyUserLogOutFailedSignal:NotifyUserLogOutFailedSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From app.
			notifyUserLoggedInSignal.add( onUserLoggedIn );
			notifyUserLoggedOutSignal.add( onUserLoggedOut );
			notifyUserLogOutFailedSignal.add( onLogOutFailed );

			// Login button.
			view.setLoginBtn( loggedInUserProxy.isLoggedIn() ? SettingsSubNavView.ID_LOGOUT : SettingsSubNavView.ID_LOGIN );
		}

		override public function destroy():void {
			super.destroy();
			notifyUserLoggedInSignal.remove( onUserLoggedIn );
			notifyUserLoggedOutSignal.remove( onUserLoggedOut );
			notifyUserLogOutFailedSignal.remove( onLogOutFailed );
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
						trace( this, "logging out" );
						loggedInUserProxy.logOut();
						view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, false );
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

		private function onUserLoggedIn():void {
			view.relabelButtonWithId( SettingsSubNavView.ID_LOGIN, SettingsSubNavView.ID_LOGOUT );
			view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, true );
		}

		private function onUserLoggedOut():void {
			view.relabelButtonWithId( SettingsSubNavView.ID_LOGIN, SettingsSubNavView.ID_LOGIN );
			view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, true );
		}
	}
}
