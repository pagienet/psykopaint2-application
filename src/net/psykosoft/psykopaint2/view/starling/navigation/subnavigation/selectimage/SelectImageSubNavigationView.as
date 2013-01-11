package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.selectimage
{

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectImageSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_FACEBOOK:String = "Facebook";
		public static const BUTTON_LABEL_CAMERA:String = "Camera";
		public static const BUTTON_LABEL_READY_TO_PAINT:String = "Ready-to-Paint";
		public static const BUTTON_LABEL_YOUR_PHOTOS:String = "Your-Photos";

		public function SelectImageSubNavigationView() {
			super();

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_FACEBOOK, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_CAMERA, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_READY_TO_PAINT, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( BUTTON_LABEL_YOUR_PHOTOS, onButtonTriggered ) );
			addButtons( buttonGroupDefinition );
		}
	}
}
