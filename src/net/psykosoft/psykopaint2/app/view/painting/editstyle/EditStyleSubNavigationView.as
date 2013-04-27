package net.psykosoft.psykopaint2.app.view.painting.editstyle
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class EditStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Pick a Style";

		public function EditStyleSubNavigationView() {
			super( "Edit Style" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			setLeftButton("FooterIconsSettings", BUTTON_LABEL_SELECT_STYLE );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[prop 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[prop 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[prop 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[prop 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );
		}
	}
}
