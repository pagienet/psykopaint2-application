package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSubNavView extends SubNavigationViewBase
	{
		public static const ID_SAVE:String = "Save";
		public static const ID_DISCARD:String = "Discard";
		//public static const ID_CLEAR:String = "Reload";
		public static const ID_DOWNLOAD:String = "Download";
		public static const ID_PUBLISH:String = "Publish";

		public static const ID_PICK_A_BRUSH:String = "Pick a Brush";
		public var isContinuedPainting:Boolean;

		public function CanvasSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			
			//setLeftButton( ID_HOME, ID_HOME, ButtonIconType.HOME );
			setRightButton( ID_PICK_A_BRUSH, ID_PICK_A_BRUSH, ButtonIconType.NEXT );
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			setHeader( "Edit Painting" );
		}

		override protected function onSetup():void {
			super.onSetup();
			createCenterButton( ID_DISCARD,  "Discard " + (isContinuedPainting ? "Changes" : ""), ButtonIconType.DISCARD );
			createCenterButton( ID_SAVE, ID_SAVE, ButtonIconType.SAVE );
			createCenterButton( ID_PUBLISH, ID_PUBLISH, ButtonIconType.PUBLISH );
			createCenterButton( ID_DOWNLOAD, "Snapshot", ButtonIconType.DOWNLOAD );
			//createCenterButton( ID_CLEAR, ID_CLEAR, ButtonIconType.CLEAR );
			validateCenterButtons();
		}
	}
}
