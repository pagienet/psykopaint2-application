package net.psykosoft.psykopaint2.app.view.navigation
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;

	public class PaintingSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SHARE:String = "[Share]";
		public static const BUTTON_LABEL_COMMENT:String = "[Comment]";
		public static const BUTTON_LABEL_EDIT:String = "[Edit]";

		public function PaintingSubNavigationView() {
			super();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "FooterIconsSettings",  BUTTON_LABEL_EDIT, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "FooterIconsGallery",  BUTTON_LABEL_SHARE, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "FooterIconsNewPainting",  BUTTON_LABEL_COMMENT, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );

		}
	}
}
