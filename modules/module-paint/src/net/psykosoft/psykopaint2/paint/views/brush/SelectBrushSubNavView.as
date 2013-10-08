package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Edit Painting";
		public static const ID_COLOR:String = "Pick a Color";
		public static const ID_ALPHA:String = "Change Opacity";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Brush" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );

			// Show color button?
			if( PaintModeModel.activeMode == PaintMode.COLOR_MODE ) {
				setRightButton( ID_COLOR, ID_COLOR, ButtonIconType.CONTINUE );
			}
			else {
				setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.CONTINUE );
			}
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String> ):void {

			var len:uint = availableBrushTypes.length;
//			trace( this, "setAvailableBrushes - len: " + len );

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
				createCenterButton( availableBrushTypes[ i ], availableBrushTypes[ i ], iconType, IconButton, null, true, true, false );
			}

			validateCenterButtons();
			selectButtonWithLabel( availableBrushTypes[ 0 ] );
		}
	}
}
