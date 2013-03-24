package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class SelectStyleSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_BRUSH:String = "Pick a Brush";
		public static const BUTTON_LABEL_EDIT_STYLE:String = "Edit Style";

		public function SelectStyleSubNavigationView() {
			super( "Select Style" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton( BUTTON_LABEL_PICK_A_BRUSH );
			setRightButton( BUTTON_LABEL_EDIT_STYLE );
		}

		public function setAvailableBrushShapes( brushShapes:Array ):void {

			clearCenterButtons();

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();

			var len:uint = brushShapes.length;
			for( var i:uint; i < len; ++i ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( brushShapes[ i ], onButtonTriggered ) );
			}

			setCenterButtons( buttonGroupDefinition );

		}
	}
}
