package net.psykosoft.psykopaint2.app.view.navigation
{

	public class BackSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";

		public function BackSubNavigationView() {
			super( "Pick an Image" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton("FooterIconsSettings", BUTTON_LABEL_BACK );
		}
	}
}
