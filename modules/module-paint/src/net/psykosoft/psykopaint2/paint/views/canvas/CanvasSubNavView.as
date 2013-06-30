package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const LBL_PICK_A_SURFACE:String = "Pick a Surface";
		public static const LBL_PICK_A_BRUSH:String = "Pick a Brush";
		public static const LBL_CLEAR:String = "Clear Canvas";
		public static const LBL_EXPORT:String = "Export Painting";
		public static const LBL_SAVE:String = "Save Painting"; // TODO: remove when auto-saving is developed
		public static const LBL_PUBLISH:String = "[Publish Painting]";
		public static const LBL_HOME:String = "Home";

		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			navigation.setHeader( "Do some painting!" );

			if( !PaintSettings.isStandalone ) {
				navigation.setLeftButton( LBL_HOME );
			}
			navigation.setRightButton( LBL_PICK_A_BRUSH );

			navigation.addCenterButton( LBL_PICK_AN_IMAGE, ButtonIconType.GALLERY );
			navigation.addCenterButton( LBL_PICK_A_SURFACE );
			navigation.addCenterButton( LBL_CLEAR );
			navigation.addCenterButton( LBL_EXPORT );
			navigation.addCenterButton( LBL_SAVE );
			navigation.addCenterButton( LBL_PUBLISH );

			navigation.layout();
		}
	}
}
