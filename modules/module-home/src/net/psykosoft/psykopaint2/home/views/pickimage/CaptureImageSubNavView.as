package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CaptureImageSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Pick an image";
		public static const ID_CAPTURE:String = "Shoot!!";
		public static const ID_FLIP:String = "Flip";

		public function CaptureImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Take a picture" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.PICTURE );
			setRightButton( ID_CAPTURE, ID_CAPTURE, ButtonIconType.CAMERA );
		}


		override protected function onSetup():void {
			createCenterButton( ID_FLIP, ID_FLIP, ButtonIconType.FLIP );
			validateCenterButtons();
		}
	}
}
