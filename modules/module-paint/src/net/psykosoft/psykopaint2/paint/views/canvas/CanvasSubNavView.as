package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.paint.configuration.PaintSettings;

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

			navigation.setHeader( "Edit Painting" );

			if( !PaintSettings.isStandalone ) {
				navigation.setLeftButton( LBL_HOME, ButtonIconType.HOME );
			}

			var centerButtonDataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();

			navigation.createCenterButtonData( centerButtonDataProvider, LBL_DESTROY, ButtonIconType.DESTROY );
			navigation.createCenterButtonData( centerButtonDataProvider, LBL_CLEAR, ButtonIconType.BLANK_CANVAS );
			navigation.createCenterButtonData( centerButtonDataProvider, LBL_EXPORT );

			navigation.scroller.setDataProvider( centerButtonDataProvider );

			navigation.setRightButton( LBL_PICK_A_BRUSH, ButtonIconType.BRUSH );

			navigation.layout();
		}
	}
}
