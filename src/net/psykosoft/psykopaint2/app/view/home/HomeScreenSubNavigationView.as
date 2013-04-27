package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.view.components.combobox.PaperComboboxView;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	
	import starling.events.Event;

	public class HomeScreenSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_NEWS1:String = "[News1]";
		public static const BUTTON_LABEL_NEWS2:String = "[News2]";
		public static const BUTTON_LABEL_NEWS3:String = "[News3]";

		public function HomeScreenSubNavigationView() {
			super( "Home" );
		}

		override protected function onEnabled():void {

			super.onEnabled();

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsSettings" ),  BUTTON_LABEL_NEWS1, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsGallery" ),  BUTTON_LABEL_NEWS2, onButtonTriggered ) );
			buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( getTextureFromId( "FooterIconsNewPainting" ),  BUTTON_LABEL_NEWS3, onButtonTriggered ) );
			setCenterButtons( buttonGroupDefinition );
			
			/*
			
			//TEST COMBOBOX
			var paperCombobox:PaperComboboxView = new PaperComboboxView();
			this.addChild(paperCombobox);
			paperCombobox.addItem({id:0,label:"SINE WAVE"});
			paperCombobox.addItem({id:1,label:"COS WAVE"});
			paperCombobox.addItem({id:2,label:"SAWTOOTH"});
			paperCombobox.addItem({id:3,label:"SQUARE"});
			paperCombobox.addItem({id:4,label:"DRAW SPEED"});
			paperCombobox.addItem({id:5,label:"ORIENTATION"});
			paperCombobox.addItem({id:6,label:"SOUND"});
			paperCombobox.x = 10;
			paperCombobox.removeItemAt(3);
			paperCombobox.addEventListener(Event.CHANGE,onChangeItem);
			
			
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
			*/
		}
		
		private function onChangeItem(e:Event):void
		{
			var combobox:PaperComboboxView = e.target as PaperComboboxView;
			trace("paperCombobox item =" +combobox.selectedItem.label)
		}
	}
}
