package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SettingsSubNavView extends SubNavigationViewBase
	{
		public static const ID_WALLPAPER:String = "Change Wallpaper";
		public static const ID_LOGIN:String = "Login";
		public static const ID_LOGOUT:String = "Logout";

		public function SettingsSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
		}

		override protected function onSetup():void {
			createCenterButton( ID_WALLPAPER, ID_WALLPAPER );
			createCenterButton( ID_LOGIN, ID_LOGIN );
			validateCenterButtons();
		}

		public function setLoginBtn( label:String ):void {
			relabelButtonWithId( ID_LOGIN, label );
		}
	}
}
