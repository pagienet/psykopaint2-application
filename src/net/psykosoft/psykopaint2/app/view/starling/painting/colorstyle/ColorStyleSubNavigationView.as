package net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class ColorStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick a Texture";

		public function ColorStyleSubNavigationView() {
			super( "Select Colors" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_PICK_AN_IMAGE );

			setRightButton( BUTTON_LABEL_PICK_A_TEXTURE );

			super.onStageAvailable();
		}

		public function setAvailableColorStyles( presetsList:Array ):void {

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			var len:uint = presetsList.length;
			for( var i:uint; i < len; ++i ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( presetsList[ i ], onButtonTriggered ) );
			}
			setCenterButtons( buttonGroupDefinition );

		}
	}
}