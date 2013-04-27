package net.psykosoft.psykopaint2.app.view.painting.selecttexture
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class SelectTextureSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_COLOR:String = "Pick a Color";
		public static const BUTTON_LABEL_PICK_A_BRUSH:String = "Pick a Brush";

		public function SelectTextureSubNavigationView() {
			super( "Select Texture" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			setLeftButton("FooterIconsSettings", BUTTON_LABEL_PICK_A_COLOR );

			// TODO: populate with actual options from the drawing core
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[tex 1]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[tex 2]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[tex 3]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  "[tex 4]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			setRightButton("FooterIconsSettings", BUTTON_LABEL_PICK_A_BRUSH );
		}
	}
}
