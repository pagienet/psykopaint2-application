package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const LBL_HOME:String = "Home";

		public static const LBL_DESTROY:String = "Destroy";
		public static const LBL_CLEAR:String = "Clear Canvas";
//		public static const LBL_MODEL:String = "Source Image";
//		public static const LBL_COLOR:String = "[Color Style]";
		public static const LBL_EXPORT:String = "Export Painting";
//		public static const LBL_SAVE:String = "Save Painting"; // TODO: remove when auto-saving is developed
//		public static const LBL_PUBLISH:String = "[Publish Painting]";

		public static const LBL_PICK_A_BRUSH:String = "Pick a Brush";

		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Edit Painting" );
			setLeftButton( LBL_HOME, ButtonIconType.HOME );
			setRightButton( LBL_PICK_A_BRUSH, ButtonIconType.BRUSH );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( LBL_DESTROY, ButtonIconType.DESTROY );
			createCenterButton( LBL_CLEAR, ButtonIconType.BLANK_CANVAS );
			createCenterButton( LBL_EXPORT );
			validateCenterButtons();
		}
	}
}
