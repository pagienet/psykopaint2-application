package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
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

			navigation.setHeader( "Pick a Surface" );
			navigation.setLeftButton( LBL_BACK, ButtonIconType.BACK );
			navigation.setRightButton( LBL_CONTINUE, ButtonIconType.MODEL );

			var centerButtonDataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();

			createCenterButtonData( centerButtonDataProvider, LBL_SURF1 );
			createCenterButtonData( centerButtonDataProvider, LBL_SURF2 );
			createCenterButtonData( centerButtonDataProvider, LBL_SURF3 );

			_scroller.setDataProvider( centerButtonDataProvider );
		}

		public function showRightButton( show:Boolean ):void {
			navigation.toggleRightButtonVisibility( show );
		}
	}
}
