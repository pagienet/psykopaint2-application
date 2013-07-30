package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class ColorStyleSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const LBL_CONFIRM:String = "Confirm";

		public function ColorStyleSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Color Style" );
			setLeftButton( LBL_PICK_AN_IMAGE, ButtonIconType.BACK );
			setRightButton( LBL_CONFIRM, ButtonIconType.OK );
		}

		public function setAvailableColorStyles( availableColorStylePresets:Array ):void {
			// TODO...
		}
	}
}
