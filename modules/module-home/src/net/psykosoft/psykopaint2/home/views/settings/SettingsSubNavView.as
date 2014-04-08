package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SettingsSubNavView extends SubNavigationViewBase
	{
		public static const ID_WALLPAPER:String = "Wallpaper";
		public static const ID_LOGIN:String = "Login";
		public static const ID_NOTIFICATIONS:String = "Notifications";
		public static const ID_PAINT_SURFACE:String = "Surface";
		public static const ID_LOGOUT:String = "Logout";

		public function SettingsSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
		}

		override protected function onSetup():void {
			createCenterButton( ID_NOTIFICATIONS, ID_NOTIFICATIONS,ButtonIconType.NOTIFICATIONS );
			//TODO LATER, BEING ABLE TO PICK PAINTING SURFACE, LIKE WOOD ETC...
			//createCenterButton( ID_PAINT_SURFACE, ID_PAINT_SURFACE,ButtonIconType.SURFACE );
			createCenterButton( ID_WALLPAPER, ID_WALLPAPER,ButtonIconType.WALLPAPER );
			createCenterButton( ID_LOGIN, ID_LOGIN,ButtonIconType.LOGIN );
			validateCenterButtons();
		}

		public function setLoginBtn( label:String ):void {
			relabelButtonWithId( ID_LOGIN, label, ButtonIconType.LOGOUT );
		}
	}
}
