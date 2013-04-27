package net.psykosoft.psykopaint2.app.view.navigation
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;

	public class ShareSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";
		public static const BUTTON_LABEL_EMAIL:String = "[Email]";
		public static const BUTTON_LABEL_SAVE:String = "[Save?]";
		public static const BUTTON_LABEL_FACEBOOK:String = "[Facebook]";
		public static const BUTTON_LABEL_INSTAGRAM:String = "[Instagram]";

		public function ShareSubNavigationView() {
			super( "Share it!" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			setLeftButton( "FooterIconsSettings", BUTTON_LABEL_BACK );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsSettings" ), BUTTON_LABEL_EMAIL, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsSettings" ), BUTTON_LABEL_SAVE, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsSettings" ), BUTTON_LABEL_FACEBOOK, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsSettings" ), BUTTON_LABEL_INSTAGRAM, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

		}
	}
}
