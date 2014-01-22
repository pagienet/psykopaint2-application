package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class ColorStyleSubNavView extends SubNavigationViewBase
	{
		public static const ID_PICK_AN_IMAGE:String = "Pick an Image";
		public static const ID_CONFIRM:String = "Confirm";

		public function ColorStyleSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Color Style" );
			setLeftButton( ID_PICK_AN_IMAGE, ID_PICK_AN_IMAGE, ButtonIconType.BACK );
			setRightButton( ID_CONFIRM, ID_CONFIRM, ButtonIconType.OK );
		}

		public function setAvailableColorStyles( availableColorStylePresets:Vector.<String> ):void {
			// TODO...
		}
	}
}
