package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class CaptureImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_SHOOT:String = "Shoot!!";

		public function CaptureImageSubNavigationView() {
			super( "Take a Picture" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE );
			setRightButton( BUTTON_LABEL_SHOOT );

			super.onStageAvailable();
		}
	}
}
