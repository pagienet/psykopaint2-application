package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomeSubNavView extends SubNavigationViewBase
	{
		public static const LBL_NEWS1:String = "[News1]";
		public static const LBL_NEWS2:String = "[News2]";
		public static const LBL_NEWS3:String = "[News3]";

		public function HomeSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Home" );

			addCenterButton( LBL_NEWS1 );
			addCenterButton( LBL_NEWS2 );
			addCenterButton( LBL_NEWS3 );

			invalidateContent();
		}
	}
}
