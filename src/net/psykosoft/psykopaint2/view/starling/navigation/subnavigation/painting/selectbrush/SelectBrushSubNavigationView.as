package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectbrush
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;

	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectBrushSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick\na Texture";
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Select\nStyle";

		public function SelectBrushSubNavigationView() {
			super( "Select Brush" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_PICK_A_TEXTURE;
			setLeftButton( leftButton );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "brush 1", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "brush 2", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "brush 3", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "brush 4", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			var rightButton:Button = new Button();
			rightButton.label = BUTTON_LABEL_SELECT_STYLE;
			setRightButton( rightButton );

			super.onStageAvailable();
		}
	}
}
