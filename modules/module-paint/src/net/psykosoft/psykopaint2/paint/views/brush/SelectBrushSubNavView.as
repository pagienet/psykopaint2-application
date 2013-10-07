package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Edit Painting";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Brush" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String> ):void {

			var len:uint = availableBrushTypes.length;
			trace( this, "setAvailableBrushes - len: " + len );

			for( var i:uint; i < len; ++i ) {
				var iconType:String;
				switch( i ) {
					case 0: {
						iconType = ButtonIconType.SPRAYCAN;
						break;
					}
					case 1: {
						iconType = ButtonIconType.BRUSH;
						break;
					}
					case 2: {
						iconType = ButtonIconType.PENCIL;
						break;
					}
					case 3: {
						iconType = ButtonIconType.WATERCOLOR;
						break;
					}
					case 4: {
						iconType = ButtonIconType.ERASER;
						break;
					}
					default: {
						iconType = ButtonIconType.DEFAULT;
					}
				}
				createCenterButton( availableBrushTypes[ i ], availableBrushTypes[ i ], iconType, IconButton, null, true );
			}

			validateCenterButtons();
			selectButtonWithLabel( availableBrushTypes[ 0 ] );
		}
	}
}
