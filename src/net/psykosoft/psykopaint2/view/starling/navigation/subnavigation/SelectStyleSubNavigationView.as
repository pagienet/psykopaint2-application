package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;

	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_BRUSH:String = "Pick\na Brush";
		public static const BUTTON_LABEL_EDIT_STYLE:String = "Edit\nStyle";

		public function SelectStyleSubNavigationView() {
			super( "Select Style" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_PICK_A_BRUSH;
			setLeftButton( leftButton );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "style 1", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "style 2", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "style 3", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "style 4", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			var rightButton:Button = new Button();
			rightButton.label = BUTTON_LABEL_EDIT_STYLE;
			setRightButton( rightButton );

			super.onStageAvailable();
		}
	}
}
