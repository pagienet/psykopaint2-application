package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting
{

	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class NewPaintingSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SELECT_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_BACK:String = "Back";

		public function NewPaintingSubNavigationView() {
			super( "New Painting" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK );

			setRightButton( BUTTON_LABEL_SELECT_IMAGE );

			super.onStageAvailable();
		}
	}
}
