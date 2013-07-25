package net.psykosoft.psykopaint2.paint.views.crop
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CropSubNavView extends SubNavigationViewBase
	{
		public static var LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static var LBL_CONFIRM_CROP:String = "Confirm";

		public function CropSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Crop!" );
			navigation.setLeftButton( LBL_PICK_AN_IMAGE, ButtonIconType.BACK );
			navigation.setRightButton( LBL_CONFIRM_CROP, ButtonIconType.OK );
		}
	}
}
