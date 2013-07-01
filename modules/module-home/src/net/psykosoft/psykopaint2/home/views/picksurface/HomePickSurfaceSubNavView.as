package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class HomePickSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_CONTINUE:String = "Continue Painting";
		public static const LBL_SURF1:String = "Canvas";
		public static const LBL_SURF2:String = "Wood";
		public static const LBL_SURF3:String = "Fur";

		public function HomePickSurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Pick a Surface" );
			navigation.setLeftButton( LBL_BACK );
			navigation.setRightButton( LBL_CONTINUE );
			navigation.addCenterButton( LBL_SURF1 );
			navigation.addCenterButton( LBL_SURF2 );
			navigation.addCenterButton( LBL_SURF3 );
			navigation.layout();
		}
	}
}
