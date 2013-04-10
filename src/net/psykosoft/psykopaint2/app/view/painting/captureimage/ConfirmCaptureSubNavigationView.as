package net.psykosoft.psykopaint2.app.view.painting.captureimage
{

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class ConfirmCaptureSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_CAPTURE:String = "Discard";
		public static const BUTTON_LABEL_KEEP:String = "keep";

		public function ConfirmCaptureSubNavigationView() {
			super( "Take a Picture" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton("FooterIconsSettings", BUTTON_LABEL_BACK_TO_CAPTURE );
			setRightButton("FooterIconsSettings", BUTTON_LABEL_KEEP );
		}
	}
}
