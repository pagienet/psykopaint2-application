package net.psykosoft.psykopaint2.app.view.settings
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class SettingsSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";
		public static const BUTTON_LABEL_WALLPAPER:String = "Wallpaper";

		public function SettingsSubNavigationView() {
			super( "Settings" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			setLeftButton("FooterIconsSettings", BUTTON_LABEL_BACK );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting", "[Notifications]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  "[Invite Friends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  "[Find Friends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  "[Your Profile]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  BUTTON_LABEL_WALLPAPER, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  "[Connect Stuff]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  "[Log Out]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );
		}
	}
}
