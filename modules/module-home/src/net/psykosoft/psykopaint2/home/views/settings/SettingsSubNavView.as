package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SettingsSubNavView extends SubNavigationViewBase
	{
		public static const LBL_WALLPAPER:String = "Change Wallpaper";

		public function SettingsSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Settings" );
		}

		override protected function onSetup():void {
			createCenterButton( LBL_WALLPAPER );
			validateCenterButtons();
		}
	}
}
