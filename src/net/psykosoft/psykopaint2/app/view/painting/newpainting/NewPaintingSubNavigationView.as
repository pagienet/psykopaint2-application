package net.psykosoft.psykopaint2.app.view.painting.newpainting
{

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class NewPaintingSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SELECT_IMAGE:String = "Pick an Image";

		public function NewPaintingSubNavigationView() {
			super( "New Painting" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setRightButton("FooterIconsSettings", BUTTON_LABEL_SELECT_IMAGE );
		}
	}
}
