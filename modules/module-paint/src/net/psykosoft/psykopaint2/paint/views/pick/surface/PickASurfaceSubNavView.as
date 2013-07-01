package net.psykosoft.psykopaint2.paint.views.pick.surface
{

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickASurfaceSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Paint";
		public static const LBL_SURF1:String = "Canvas";
		public static const LBL_SURF2:String = "Wood";
		public static const LBL_SURF3:String = "Fur";

		private var _group:ButtonGroup;

		public function PickASurfaceSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Pick a Surface" );

			navigation.setLeftButton( LBL_BACK );

			_group = new ButtonGroup();
			_group.addButton( navigation.createButton( LBL_SURF1 ) );
			_group.addButton( navigation.createButton( LBL_SURF2 ) );
			_group.addButton( navigation.createButton( LBL_SURF3 ) );

			 _group.setSelectedButtonByLabel( LBL_SURF1 );

			navigation.layout();
		}

		public function setSelectedSurfaceBtn( ):void {
			_group.setSelectedButtonByLabel( PickASurfaceCache.getLastSelectedSurface() );
		}
	}
}
