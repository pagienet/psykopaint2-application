package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.view.components.checkbox.PaperCheckBox;
	import net.psykosoft.psykopaint2.app.view.components.sliders.PaperRangeSlider;
	import net.psykosoft.psykopaint2.app.view.components.sliders.PaperSlider;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Image;

	public class HomeScreenSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_SETTINGS:String = "Settings";
		public static const BUTTON_LABEL_GALLERY:String = "[Gallery]";
		public static const BUTTON_LABEL_NEW_PAINTING:String = "New Painting";

		public function HomeScreenSubNavigationView() {
			super( "Home" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsSettings",  BUTTON_LABEL_SETTINGS, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsGallery",  BUTTON_LABEL_GALLERY, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO("FooterIconsNewPainting",  BUTTON_LABEL_NEW_PAINTING, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );
			
			
			//TEST ADD SLIDER
			var hslider:PaperSlider = new PaperSlider();
			this.addChild(hslider);
			hslider.x = 10;
			
			//TEST ADD SLIDER
			var hRangeSlider:PaperRangeSlider = new PaperRangeSlider();
			this.addChild(hRangeSlider);
			hRangeSlider.x = 300;
			
			//TEST ADD CHECKBOX
			var papercheckbox:PaperCheckBox = new PaperCheckBox();
			this.addChild(papercheckbox);
			papercheckbox.x = 850;
			
		}
	}
}
