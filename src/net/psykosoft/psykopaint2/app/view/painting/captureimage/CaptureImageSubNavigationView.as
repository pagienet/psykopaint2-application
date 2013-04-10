package net.psykosoft.psykopaint2.app.view.painting.captureimage
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class CaptureImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_SHOOT:String = "Shoot!!";
		public static const BUTTON_LABEL_FLIP:String = "Flip";

		public function CaptureImageSubNavigationView() {
			super( "Take a Picture" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			setLeftButton("FooterIconsSettings", BUTTON_LABEL_BACK_TO_PICK_AN_IMAGE );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  BUTTON_LABEL_FLIP, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			setRightButton("FooterIconsGallery", BUTTON_LABEL_SHOOT );
		}
	}
}
