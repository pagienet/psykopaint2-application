package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class EditStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Pick a Style";

		public function EditStyleSubNavigationView() {
			super( "Edit Style" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_SELECT_STYLE );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[prop 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[prop 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[prop 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[prop 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			super.onStageAvailable();
		}
	}
}
