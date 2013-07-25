package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SettingsSubNavView extends SubNavigationViewBase
	{
		public static const LBL_WALLPAPER:String = "Change Wallpaper";

		public function SettingsSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			navigation.setHeader( "Settings" );

			var centerButtonDataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();
			navigation.createCenterButtonData( centerButtonDataProvider, LBL_WALLPAPER );

			navigation.layout();
		}
	}
}
