package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_CONTINUE:String = "Ok";
		public static const LBL_SURF1:String = "Canvas";
		public static const LBL_SURF2:String = "Paper";
		public static const LBL_SURF3:String = "Wood";

		private var _group:ButtonGroup;

		public function PickSurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			navigation.setHeader( "Pick a Surface" );
			navigation.setLeftButton( LBL_BACK, ButtonIconType.BACK );
			navigation.setRightButton( LBL_CONTINUE, ButtonIconType.MODEL );

			_group = new ButtonGroup();
			_group.addButton( navigation.createButton( LBL_SURF1 ) );
			_group.addButton( navigation.createButton( LBL_SURF2 ) );
			_group.addButton( navigation.createButton( LBL_SURF3 ) );
			navigation.addCenterButtonGroup( _group );
			navigation.layout();
		}

		public function showRightButton( show:Boolean ):void {
			navigation.toggleRightButtonVisibility( show );
		}
	}
}
