package net.psykosoft.psykopaint2.paint.views.pick.surface
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickASurfaceSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Paint";
		public static const LBL_SURF1:String = "Canvas";
		public static const LBL_SURF2:String = "Wood";
		public static const LBL_SURF3:String = "Fur";

		public function PickASurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setLabel( "Pick a Surface" );
			setLeftButton( LBL_BACK );
			addCenterButton( LBL_SURF1 );
			addCenterButton( LBL_SURF2 );
			addCenterButton( LBL_SURF3 );
			invalidateContent();
		}
	}
}
