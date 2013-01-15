package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_FACEBOOK:String = "Facebook";
		public static const BUTTON_LABEL_CAMERA:String = "Camera";
		public static const BUTTON_LABEL_READY_TO_PAINT:String = "Ready\nto Paint";
		public static const BUTTON_LABEL_YOUR_PHOTOS:String = "Your\nPhotos";
		public static const BUTTON_LABEL_NEW_PAINTING:String = "New\nPainting";

		public function SelectImageSubNavigationView() {
			super( "Select Image" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_NEW_PAINTING;
			setLeftButton( leftButton );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_FACEBOOK, onButtonTriggered, false ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_CAMERA, onButtonTriggered, false ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_READY_TO_PAINT, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_YOUR_PHOTOS, onButtonTriggered, false ) );
			setCenterButtons( buttonGroupDefinition );

			super.onStageAvailable();
		}
	}
}
