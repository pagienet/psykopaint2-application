package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectBrushSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick a Texture";
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Select Style";

		public function SelectBrushSubNavigationView() {
			super( "Select Brush" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_PICK_A_TEXTURE );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[brush 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[brush 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[brush 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[brush 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			setRightButton( BUTTON_LABEL_SELECT_STYLE );

			super.onStageAvailable();
		}
	}
}
