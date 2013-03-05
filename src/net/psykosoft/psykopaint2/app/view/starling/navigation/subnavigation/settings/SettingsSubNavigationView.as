package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SettingsSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";
		public static const BUTTON_LABEL_WALLPAPER:String = "Wallpaper";

		public function SettingsSubNavigationView() {
			super( "Settings" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Notifications]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Invite Friends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Find Friends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Your Profile]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_WALLPAPER, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Connect Stuff]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Log Out]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			super.onStageAvailable();
		}
	}
}
