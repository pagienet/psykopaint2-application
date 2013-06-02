package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PAINT:String = "Paint";

		public function HomeSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Home" );

			if( !HomeSettings.isStandalone ) {
				addCenterButton( LBL_PAINT );
			}

			invalidateContent();
		}
	}
}
