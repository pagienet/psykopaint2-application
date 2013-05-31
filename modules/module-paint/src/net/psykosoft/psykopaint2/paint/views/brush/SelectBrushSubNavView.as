package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_SELECT_SHAPE:String = "Pick a Shape";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Pick a Brush" );

			setLeftButton( LBL_BACK );
			setRightButton( LBL_SELECT_SHAPE );

			invalidateContent();
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String> ):void {
			areButtonsSelectable( true );
			var len:uint = availableBrushTypes.length;
			for( var i:uint; i < len; ++i ) {
				addCenterButton( availableBrushTypes[ i ] );
			}
			invalidateContent();
		}

		public function setSelectedBrush( activeBrushKit:String ):void {
			selectButtonWithLabel( activeBrushKit );
		}
	}
}
