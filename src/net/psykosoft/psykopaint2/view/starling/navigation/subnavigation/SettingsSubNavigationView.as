package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;

	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SettingsSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";
		public static const BUTTON_LABEL_WALLPAPER:String = "Wallpaper";

		public function SettingsSubNavigationView() {
			super( "Settings" );
		}

		override protected function onStageAvailable():void {

			var leftButton:Button = new Button();
			leftButton.label = BUTTON_LABEL_BACK;
			setLeftButton( leftButton );

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Notifications]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Invite\nFriends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Find\nFriends]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Your\nProfile]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_WALLPAPER, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Connect\nStuff]", onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "[Log\nOut]", onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

			super.onStageAvailable();
		}
	}
}
