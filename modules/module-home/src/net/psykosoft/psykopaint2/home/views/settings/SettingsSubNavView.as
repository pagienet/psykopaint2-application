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

			navigation.setHeader( "Settings" );
//

			navigation.addCenterButton( LBL_WALLPAPER );
			navigation.addCenterButton( "[setting1]" );
			navigation.addCenterButton( "[setting2]" );
			navigation.addCenterButton( "[setting3]" );
			navigation.addCenterButton( "[setting4]" );

			navigation.layout();
		}
	}
}
