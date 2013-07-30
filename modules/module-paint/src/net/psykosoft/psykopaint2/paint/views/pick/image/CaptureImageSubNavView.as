package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CaptureImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Pick an image";
		public static const LBL_CAPTURE:String = "Shoot!!";
		public static const LBL_FLIP:String = "Flip";

		public function CaptureImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Take a picture" );
			setLeftButton( LBL_BACK, ButtonIconType.PICTURE );
			setRightButton( LBL_CAPTURE, ButtonIconType.CAMERA );
		}


		override protected function onSetup():void {
			createCenterButton( LBL_FLIP, ButtonIconType.FLIP );
			validateCenterButtons();
		}
	}
}
