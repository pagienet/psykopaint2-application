package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_CONTINUE:String = "Ok";
		public static const LBL_SURF1:String = "Canvas";
		public static const LBL_SURF2:String = "Paper";
		public static const LBL_SURF3:String = "Wood";

		public function PickSurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Surface" );
			setLeftButton( LBL_BACK, ButtonIconType.BACK );
			setRightButton( LBL_CONTINUE, ButtonIconType.MODEL );
		}

		override protected function onSetup():void {
			createCenterButton( LBL_SURF1 );
			createCenterButton( LBL_SURF2 );
			createCenterButton( LBL_SURF3 );
			validateCenterButtons();
			super.onSetup();
		}
	}
}
