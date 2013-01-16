package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectColorsSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_AN_IMAGE:String = "Pick\nan Image";
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick\na Texture";

		public function SelectColorsSubNavigationView() {
			super( "Select Colors" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_PICK_AN_IMAGE;
			setLeftButton( leftButton );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 4]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 5]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 6]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 7]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 8]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 9]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 10]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 11]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 12]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[colors 13]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			var rightButton:Button = new Button();
			rightButton.label = BUTTON_LABEL_PICK_A_TEXTURE;
			setRightButton( rightButton );

			super.onStageAvailable();
		}
	}
}
