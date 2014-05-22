package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SettingsSubNavView extends SubNavigationViewBase
	{
		public static const ID_WALLPAPER:String = "Wallpaper";
		public static const ID_CANVAS_SURFACE:String = "Surface";
		public static const ID_LOGIN:String = "Login";
		public static const ID_LOGOUT:String = "Logout";
		public static const ID_NOTIFICATION_SETTINGS:String = "Notifications";
		public static const ID_CONNECT_PEN:String = "Connect Pen";

		public function SettingsSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
		}

		override protected function onSetup():void {
			createCenterButton( ID_CANVAS_SURFACE, ID_CANVAS_SURFACE, ButtonIconType.SURFACE );
			createCenterButton( ID_WALLPAPER, ID_WALLPAPER,ButtonIconType.WALLPAPER );
			createCenterButton( ID_LOGIN, ID_LOGIN,ButtonIconType.LOGIN );
			createCenterButton( ID_NOTIFICATION_SETTINGS, ID_NOTIFICATION_SETTINGS, ButtonIconType.NOTIFICATIONS );
			createCenterButton( ID_CONNECT_PEN, ID_CONNECT_PEN, ButtonIconType.PENCIL );
			validateCenterButtons();
		}

		public function setLoginBtn( label:String ):void {
			relabelButtonWithId( ID_LOGIN, label, ButtonIconType.LOGOUT );
		}
		
		public function hidePenButton():void
		{
			//TODO: fix button removal from hscroller
		}
	}
}
