package net.psykosoft.psykopaint2.crop.views
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CropSubNavView extends SubNavigationViewBase
	{
		public static var ID_PICK_AN_IMAGE:String = "Pick an Image";
		public static var ID_CONFIRM_CROP:String = "Confirm";

		public function CropSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Crop!" );
			setLeftButton( ID_PICK_AN_IMAGE, ID_PICK_AN_IMAGE, ButtonIconType.BACK );
			setRightButton( ID_CONFIRM_CROP, ID_CONFIRM_CROP, ButtonIconType.OK );
		}
	}
}
