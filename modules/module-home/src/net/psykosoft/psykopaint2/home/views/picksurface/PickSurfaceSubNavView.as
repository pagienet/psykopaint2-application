package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_SURF1:String = "Canvas";
		public static const ID_SURF2:String = "Paper";
		public static const ID_SURF3:String = "Wood";

		public function PickSurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Surface" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
		}

		override protected function onSetup():void {
			createCenterButton( ID_SURF1, ID_SURF1 );
			createCenterButton( ID_SURF2, ID_SURF2 );
			createCenterButton( ID_SURF3, ID_SURF3 );
			validateCenterButtons();
			super.onSetup();
		}
	}
}
