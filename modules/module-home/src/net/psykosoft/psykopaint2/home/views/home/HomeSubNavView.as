package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PAINT:String = "Paint";

		public function HomeSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Home" );

			addCenterButton( LBL_PAINT );

			invalidateContent();
		}
	}
}
