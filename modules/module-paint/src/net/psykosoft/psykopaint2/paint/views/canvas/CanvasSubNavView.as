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

			addCenterButton( "[1]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[2]", NavigationButtonIconType.NEW );
			addCenterButton( "[3]", NavigationButtonIconType.SETTINGS );
			addCenterButton( "[4]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[5]", NavigationButtonIconType.NEW );
			addCenterButton( "[6]", NavigationButtonIconType.SETTINGS );
			addCenterButton( "[7]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[8]", NavigationButtonIconType.NEW );
			addCenterButton( "[9]", NavigationButtonIconType.SETTINGS );
			addCenterButton( "[10]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[11]", NavigationButtonIconType.NEW );
			addCenterButton( "[12]", NavigationButtonIconType.SETTINGS );
			addCenterButton( "[13]", NavigationButtonIconType.GALLERY );
			addCenterButton( "[14]", NavigationButtonIconType.NEW );
			addCenterButton( "[15]", NavigationButtonIconType.SETTINGS );

			invalidateContent();
		}
	}
}
