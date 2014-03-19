package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.model.PaintModeModel;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Edit Painting";
		public static const ID_COLOR:String = "Paint Settings";
	//	public static const ID_ALPHA:String = "Change Opacity";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Pick a Brush" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			setRightButton( ID_COLOR, ID_COLOR, ButtonIconType.TWEAK_BRUSH );
			/*
			// Show color button?
			if( PaintModeModel.activeMode == PaintMode.COLOR_MODE ) {
				
			}
			else {
				setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			}
			*/
			//setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
		}

		public function setColorButtonHex( argb:uint ):void {
			var icon:Sprite = getButtonIconForRightButton();
			if( icon ) {
				var ct:ColorTransform = new ColorTransform();
				ct.color = argb;
				var overlay:Sprite = icon.getChildByName( "overlay" ) as Sprite;
				overlay.transform.colorTransform = ct;
			}
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String>, selectedId:String ):void {

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
						iconType = ButtonIconType.TRY_BRUSH;
						break;
					}
					case 2: {
						iconType = ButtonIconType.TRY_PENCIL;
						break;
					}
					case 3: {
						iconType = ButtonIconType.TRY_WATERCOLOR;
						break;
					}
					case 4: {
						iconType = ButtonIconType.ERASER;
						break;
					}
					default: {
						iconType = ButtonIconType.TRY_BRUSH;
					}
				}
				createCenterButton( availableBrushTypes[ i ], availableBrushTypes[ i ], iconType, IconButton, null, true, true, false );
			}

			validateCenterButtons();
			selectButtonWithLabel(selectedId);
		}
	}
}
