package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class ConfirmCaptureSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_CAPTURE:String = "Discard";
		public static const BUTTON_LABEL_KEEP:String = "keep";

		public function ConfirmCaptureSubNavigationView() {
			super( "Take a Picture" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK_TO_CAPTURE );
			setRightButton( BUTTON_LABEL_KEEP );

			super.onStageAvailable();
		}
	}
}
