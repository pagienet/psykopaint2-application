package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const LBL_HOME:String = "Home";

		public static const LBL_DESTROY:String = "[Destroy]";
		public static const LBL_CLEAR:String = "Clear Canvas";
		public static const LBL_MODEL:String = "Source Image";
		public static const LBL_COLOR:String = "[Color Style]";
		public static const LBL_EXPORT:String = "Export Painting";
		public static const LBL_SAVE:String = "Save Painting"; // TODO: remove when auto-saving is developed
		public static const LBL_PUBLISH:String = "[Publish Painting]";

		public static const LBL_PICK_A_BRUSH:String = "Pick a Brush";

		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			navigation.setHeader( "Do some painting!" );

			if( !PaintSettings.isStandalone ) {
				navigation.setLeftButton( LBL_HOME );
			}

			navigation.addCenterButton( LBL_DESTROY );
			navigation.addCenterButton( LBL_CLEAR );
			navigation.addCenterButton( LBL_MODEL );
			navigation.addCenterButton( LBL_COLOR );
			navigation.addCenterButton( LBL_EXPORT );
			navigation.addCenterButton( LBL_SAVE );
			navigation.addCenterButton( LBL_PUBLISH );

			navigation.setRightButton( LBL_PICK_A_BRUSH );

			navigation.layout();
		}
	}
}
