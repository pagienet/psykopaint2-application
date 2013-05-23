package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.components.CrNavigationButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.CrSubNavigationViewBase;

	public class PtCanvasSubNavView extends CrSubNavigationViewBase
	{
		public static const LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const LBL_PICK_A_BRUSH:String = "Pick a Brush";
		
		public function PtCanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Do some painting!" );

			setLeftButton( LBL_PICK_AN_IMAGE );
			setRightButton( LBL_PICK_A_BRUSH );

			addCenterButton( "[Pick a Color Style]", CrNavigationButtonIconType.GALLERY );
			addCenterButton( "[Pick a Surface]", CrNavigationButtonIconType.NEW );
			addCenterButton( "[TestB]", CrNavigationButtonIconType.SETTINGS );

			invalidateContent();
		}
	}
}
