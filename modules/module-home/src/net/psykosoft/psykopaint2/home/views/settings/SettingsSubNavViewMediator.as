package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
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
		
		[Inject]
		public var wacomPenManager:WacomPenManager;
		
		

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
			view.setLoginBtn( !loggedInUserProxy.isLoggedIn() );
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
				case SettingsSubNavView.ID_CANVAS_SURFACE:
					requestNavigationStateChange( NavigationStateType.SETTINGS_CANVAS_SURFACE );
					break;

				case SettingsSubNavView.ID_WALLPAPER:
					requestNavigationStateChange( NavigationStateType.SETTINGS_WALLPAPER );
					break;
				case SettingsSubNavView.ID_HELP:
					requestNavigationStateChange( NavigationStateType.SETTINGS_HELP );
					break;

				case SettingsSubNavView.ID_LOGIN:
					handleLogInClicked();
					break;

				case SettingsSubNavView.ID_NOTIFICATION_SETTINGS:
					handleNotificationsClicked();
					break;
				
				case SettingsSubNavView.ID_CONNECT_PEN:
					WacomPenManager.initializePen();
					view.hidePenButton();
					break;
			}
		}

		private function handleNotificationsClicked():void
		{
			if (loggedInUserProxy.isLoggedIn())
				requestShowPopUpSignal.dispatch(PopUpType.NOTIFICATION_SETTINGS);
			else
				requestShowPopUpSignal.dispatch(PopUpType.LOGIN);
		}

		private function handleLogInClicked():void
		{
			if (loggedInUserProxy.isLoggedIn()) {
				view.enableButtonWithId(SettingsSubNavView.ID_LOGIN, false);
				trace(this, "logging out");
				// no need to check for success, is implicit in onChange
				loggedInUserProxy.logOut(null, onLogOutFailed);
			}
			else {
				trace(this, "logging in");
				requestShowPopUpSignal.dispatch(PopUpType.LOGIN);
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onLogOutFailed( amfErrorCode:int, reason:String ):void {
			trace( this, "log out failed - error code: " + amfErrorCode );
		}

		private function onLoggedInUserChange():void {
		
			view.setLoginBtn(!loggedInUserProxy.isLoggedIn());
			
			view.enableButtonWithId( SettingsSubNavView.ID_LOGIN, true );
		}
	}
}
