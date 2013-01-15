package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.homescreen
{

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class HomeScreenSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SETTINGS:String = "Settings";
		public static const BUTTON_LABEL_GALLERY:String = "Gallery";
		public static const BUTTON_LABEL_NEW_PAINTING:String = "New\nPainting";

		public function HomeScreenSubNavigationView() {
			super( "Home" );
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_SETTINGS, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_GALLERY, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_NEW_PAINTING, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );
		}

	}
}
