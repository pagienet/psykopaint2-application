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

			navigation.setHeader( "Pick a Color Style" );



			navigation.setLeftButton( LBL_PICK_AN_IMAGE, ButtonIconType.BACK );
			navigation.setRightButton( LBL_CONFIRM, ButtonIconType.OK );

			navigation.layout();
		}

		public function setAvailableColorStyles( availableColorStylePresets:Array ):void {
			var len:uint = availableColorStylePresets.length;
			for( var i:uint; i < len; ++i ) {
				navigation.addCenterButton( availableColorStylePresets[ i ] );
			}
			navigation.layout();
		}
	}
}
