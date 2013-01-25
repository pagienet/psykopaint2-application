package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_BRUSH:String = "Pick a Brush";
		public static const BUTTON_LABEL_EDIT_STYLE:String = "Edit Style";

		public function SelectStyleSubNavigationView() {
			super( "Select Style" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_PICK_A_BRUSH );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[style 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[style 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[style 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[style 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			setRightButton( BUTTON_LABEL_EDIT_STYLE );

			super.onStageAvailable();
		}
	}
}
