package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Edit Painting";
		public static const LBL_EDIT_BRUSH:String = "Edit Brush";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Pick a Brush" );
			navigation.setLeftButton( LBL_BACK, ButtonIconType.BACK );
			navigation.setRightButton( LBL_EDIT_BRUSH, ButtonIconType.TWEAK_BRUSH );
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String> ):void {
			var len:uint = availableBrushTypes.length;

			var centerButtonDataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();

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

				createCenterButtonData( centerButtonDataProvider, availableBrushTypes[ i ], iconType );
			}
			_scroller.setDataProvider( centerButtonDataProvider );
		}

		public function setSelectedBrush( activeBrushKit:String ):void {
			// TODO: complete navigation refactor
//			EditBrushSubNavView.setLastSelectedBrush( activeBrushKit );
//			_group.setSelectedButtonByLabel( activeBrushKit );
		}
	}
}
