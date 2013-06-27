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
			setLabel( "Pick a Surface" );
			areButtonsSelectable( true );
			setLeftButton( LBL_BACK );
			setRightButton( LBL_CONTINUE );
			addCenterButton( LBL_SURF1 );
			addCenterButton( LBL_SURF2 );
			addCenterButton( LBL_SURF3 );
			invalidateContent();
		}
	}
}
