package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PAINT:String = "Paint";
		public static const LBL_NEWS2:String = "[News2]";
		public static const LBL_NEWS3:String = "[News3]";

		public function HomeSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Home" );

			addCenterButton( LBL_PAINT );
			addCenterButton( LBL_NEWS2 );
			addCenterButton( LBL_NEWS3 );

			invalidateContent();
		}
	}
}
