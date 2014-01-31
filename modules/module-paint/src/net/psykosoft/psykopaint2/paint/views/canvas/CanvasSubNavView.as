package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const ID_SAVE:String = "Save It";
		public static const ID_DISCARD:String = "Discard It";
	//	public static const ID_CLEAR:String = "Clear Canvas";
		public static const ID_DOWNLOAD:String = "Download It";
	//	public static const ID_PUBLISH:String = "Publish Painting";

		public static const ID_PICK_A_BRUSH:String = "Pick a Brush";

		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Edit Painting" );
			//setLeftButton( ID_HOME, ID_HOME, ButtonIconType.HOME );
			setRightButton( ID_PICK_A_BRUSH, ID_PICK_A_BRUSH, ButtonIconType.BRUSH );
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( ID_SAVE, ID_SAVE, ButtonIconType.SAVE );
		
			createCenterButton( ID_DOWNLOAD, ID_DOWNLOAD, ButtonIconType.DOWNLOAD );
			createCenterButton( ID_DISCARD, ID_DISCARD, ButtonIconType.DISCARD );
			//createCenterButton( ID_PUBLISH, ID_PUBLISH, ButtonIconType.PUBLISH );
			//createCenterButton( ID_CLEAR, ID_CLEAR, ButtonIconType.BLANK_CANVAS );
			validateCenterButtons();
		}
	}
}
