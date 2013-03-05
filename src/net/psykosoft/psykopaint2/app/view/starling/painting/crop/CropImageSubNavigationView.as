package net.psykosoft.psykopaint2.app.view.starling.painting.crop
{

	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class CropImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_CROP:String = "Crop!!";

		public function CropImageSubNavigationView() {
			super( "Crop Image" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE );

			setRightButton( BUTTON_LABEL_CROP );

			super.onStageAvailable();
		}
	}
}