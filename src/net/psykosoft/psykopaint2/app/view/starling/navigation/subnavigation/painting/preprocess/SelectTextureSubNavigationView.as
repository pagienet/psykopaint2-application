package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectTextureSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_COLOR:String = "Pick a Color";
		public static const BUTTON_LABEL_PICK_A_BRUSH:String = "Pick a Brush";

		public function SelectTextureSubNavigationView() {
			super( "Select Texture" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_PICK_A_COLOR );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[tex 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[tex 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[tex 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[tex 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			setRightButton( BUTTON_LABEL_PICK_A_BRUSH );

			super.onStageAvailable();
		}
	}
}
