package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class NewPaintingSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SELECT_IMAGE:String = "Pick\nan Image";
		public static const BUTTON_LABEL_BACK:String = "Back";

		public function NewPaintingSubNavigationView() {
			super( "New Painting" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_BACK;
			setLeftButton( leftButton );

			var rightButton:Button = new Button();
			rightButton.label = BUTTON_LABEL_SELECT_IMAGE;
			setRightButton( rightButton );

			super.onStageAvailable();
		}
	}
}
