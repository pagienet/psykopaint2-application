package net.psykosoft.psykopaint2.app.view.starling.painting.canvas
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectBrushSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick a Texture";
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Select Style";

		public function SelectBrushSubNavigationView() {
			super( "Select Brush" );
		}

		override protected function onStageAvailable():void {
			setLeftButton( BUTTON_LABEL_PICK_A_TEXTURE );
			setRightButton( BUTTON_LABEL_SELECT_STYLE );
			super.onStageAvailable();
		}

		public function setAvailableBrushes( availableBrushShapes:Array ):void {

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();

			var len:uint = availableBrushShapes.length;
			for( var i:uint; i < len; ++i ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( availableBrushShapes[ i ], onButtonTriggered ) );
			}

			setCenterButtons( buttonGroupDefinition );

		}
	}
}
