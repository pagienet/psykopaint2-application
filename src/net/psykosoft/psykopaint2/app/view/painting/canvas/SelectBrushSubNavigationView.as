package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_PICK_A_TEXTURE:String = "Pick a Texture";
		public static const BUTTON_LABEL_SELECT_STYLE:String = "Select Style";

		private var _initialized:Boolean;

		public function SelectBrushSubNavigationView() {
			super( "Select Brush" );
		}

		override protected function onStageAvailable():void {
			setLeftButton( BUTTON_LABEL_PICK_A_TEXTURE );
			setRightButton( BUTTON_LABEL_SELECT_STYLE );
			super.onStageAvailable();
		}

		public function setAvailableBrushes( brushTypes:Vector.<String> ):void {

			if( _initialized ) return;

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();

			var len:uint = brushTypes.length;
			for( var i:uint; i < len; ++i ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( brushTypes[ i ], onButtonTriggered ) );
			}

			setCenterButtons( buttonGroupDefinition );

			_initialized = true;

		}
	}
}
