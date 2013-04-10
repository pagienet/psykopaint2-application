package net.psykosoft.psykopaint2.app.view.painting.crop
{

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class CropImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_CROP:String = "Crop!!";

		public function CropImageSubNavigationView() {
			super( "Crop Image" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton("FooterIconsSettings", BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE );
			setRightButton("FooterIconsSettings", BUTTON_LABEL_CROP );
		}
	}
}
