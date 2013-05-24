package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.components.NavigationButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const LBL_PICK_A_BRUSH:String = "Pick a Brush";
		
		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Do some painting!" );

			setLeftButton( LBL_PICK_AN_IMAGE );
			setRightButton( LBL_PICK_A_BRUSH );

			addCenterButton( "[Pick a Color Style]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[Pick a Surface]", NavigationButtonIconType.NEW );
			addCenterButton( "[TestB]", NavigationButtonIconType.SETTINGS );

			invalidateContent();
		}
	}
}