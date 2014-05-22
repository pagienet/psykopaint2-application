package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.core.data.UserConfigVO;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit_BristleBrush;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		public static const ID_COLOR:String = "Paint Settings";
	//	public static const ID_ALPHA:String = "Change Opacity";

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			setHeader( "Pick a Brush" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			setRightButton( ID_COLOR, ID_COLOR, ButtonIconType.NEXT );
			/*
			// Show color button?
			if( PaintModeModel.activeMode == PaintMode.COLOR_MODE ) {
				
			}
			else {
				setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			}
			*/
			//setRightButton( ID_ALPHA, ID_ALPHA, ButtonIconType.ALPHA );
			
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

		public function setAvailableBrushes( availableBrushTypes:Vector.<String>, selectedId:String, userConfig:UserConfigVO ):void {

			var len:uint = availableBrushTypes.length;
//			trace( this, "setAvailableBrushes - len: " + len );

			for( var i:uint; i < len; ++i ) {
				var iconType:String;
				switch( i ) 
				{
					case 0: 
						iconType = ButtonIconType.SPRAYCAN;
						break;
					
					case 1: 
						iconType = userConfig.userOwns( Vector.<String>([InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_BRISTLE_BRUSH_1])) ? ButtonIconType.BRUSH : ButtonIconType.TRY_BRUSH;
						break;
					
					case 2: 
						iconType = userConfig.userOwns( Vector.<String>([InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_PENCIL_BRUSH_1])) ? ButtonIconType.PENCIL : ButtonIconType.TRY_PENCIL;
						break;
					
					case 3: 
						iconType = userConfig.userOwns( Vector.<String>([InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_WATERCOLOR_BRUSH_1])) ? ButtonIconType.WATERCOLOR : ButtonIconType.TRY_WATERCOLOR;
						break;
					
					case 4: 
						iconType = userConfig.userOwns( Vector.<String>([InAppPurchaseManager.PRODUCT_ID_BRUSHKIT1, InAppPurchaseManager.PRODUCT_ID_PAINTGUN_BRUSH_1])) ? ButtonIconType.PAINTGUN : ButtonIconType.TRY_PAINTGUN;
						break;
					
					case 5: 
						iconType = userConfig.userOwns( Vector.<String>([InAppPurchaseManager.PRODUCT_ID_BRUSHKIT2, InAppPurchaseManager.PRODUCT_ID_COSMETICS_BRUSH_1])) ? ButtonIconType.COSMETICS : ButtonIconType.TRY_COSMETICS;
						break;
					
					default: 
						throw("SelectBrushSubNavView: unhandled brush id "+i);
						break;
					
				}
				createCenterButton( availableBrushTypes[ i ], availableBrushTypes[ i ], iconType, IconButton, null, true, true, false );
			}

			validateCenterButtons();
			selectButtonWithLabel(selectedId);
		}
	}
}
