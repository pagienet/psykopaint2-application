package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.views.navigation.CrSubNavigationViewBase;

	public class PtColorStyleSubNavView extends CrSubNavigationViewBase
	{
		public static const LBL_PICK_AN_IMAGE:String = "Pick an Image";
		public static const LBL_CONFIRM:String = "Confirm";

		public function PtColorStyleSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Pick a Color Style" );

			areButtonsSelectable( true );

			setLeftButton( LBL_PICK_AN_IMAGE );
			setRightButton( LBL_CONFIRM );

			invalidateContent();
		}

		public function setAvailableColorStyles( availableColorStylePresets:Array ):void {
			var len:uint = availableColorStylePresets.length;
			for( var i:uint; i < len; ++i ) {
				addCenterButton( availableColorStylePresets[ i ] );
			}
			invalidateContent();
		}
	}
}
