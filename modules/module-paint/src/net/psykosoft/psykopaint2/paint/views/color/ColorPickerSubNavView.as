package net.psykosoft.psykopaint2.paint.views.color
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyChangePipetteColorSignal;
	
	public class ColorPickerSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		
		private var _uiElements:Vector.<DisplayObject>;
		private var _parameterSetVO:ParameterSetVO;
		private var _parameter:PsykoParameter;
		
		public static const CUSTOM_COLOR_ID:String = "Custom Color";
		private const UI_ELEMENT_Y:uint = 320;

		private var _userPaintSettings:UserPaintSettingsModel;
		
		public var hslSliders:HSLSliders;
		public var brushStyleUI:StyleUI;
		public var colorPalette:ColorPalette;
		private var photoStyleUI:StyleUI;
		
		public var notifyChangePipetteColorSignal:NotifyChangePipetteColorSignal;
		public var renderer:CanvasRenderer;
	
		
		private var currentSwatchMixRed:Number;
		private var currentSwatchMixGreen:Number;
		private var currentSwatchMixBlue:Number;
		
		private var selectedPipetteChargeSwatch:Sprite;
		private var previousRendererSourceTextureAlpha:Number;
		private var previousRendererPaintAlpha:Number;
		private var sourcePreviewActive:Boolean;

		private var blendFactor:Number;
		private var blendFactorIncrease:Number;
		
		
		private var styleParameter:PsykoParameter;
		private var slider1Parameter:PsykoParameter;
		private var slider2Parameter:PsykoParameter;
		
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;
		
		
		public function ColorPickerSubNavView()
		{
			super();
		}
		
		override public function setup():void
		{
			super.setup();
			
			brushStyleUI.setParameters(styleParameter,slider1Parameter,slider2Parameter);
			brushStyleUI.setup(1,2);
			hslSliders.setup();
			photoStyleUI = new StyleUI();
			photoStyleUI.setParameters(_userPaintSettings.colorStyleParameter,_userPaintSettings.styleBlendParameter,_userPaintSettings.previewMixtureParameter);
			
			photoStyleUI.x = hslSliders.x - 32;
			photoStyleUI.y = brushStyleUI.y;
			photoStyleUI.setup(3,4);
			addChild(photoStyleUI);
			photoStyleUI.visible = false;
			
			//colorStyleParameter = new PsykoParameter( PsykoParameter.IconListParameter,"Color Style",0,["No Style","Contrast Style","Black and White Style","Supersaturated Style","Mona Lisa Style","William Turner Style","Miro Style","Picasso Style"]);
			
			_userPaintSettings.colorStyleParameter.addEventListener(Event.CHANGE, onStyleParameterChanged );
			_userPaintSettings.styleBlendParameter.addEventListener(Event.CHANGE, onBlendParameterChanged );
			_userPaintSettings.previewMixtureParameter.addEventListener(Event.CHANGE,onPreviewMixtureChanged );
			
			photoStyleUI.setSnappings(null,Vector.<Number>([0.5]));
			//this must be called at the end since it will trigger color change signals
			colorPalette.setUserPaintSettings( _userPaintSettings );
		}
		
		override protected function onDisabled():void
		{
			super.onDisabled();
			_userPaintSettings.colorStyleParameter.removeEventListener(Event.CHANGE, onStyleParameterChanged );
			_userPaintSettings.styleBlendParameter.removeEventListener(Event.CHANGE, onBlendParameterChanged );
			_userPaintSettings.previewMixtureParameter.removeEventListener(Event.CHANGE,onPreviewMixtureChanged );
			userPaintSettings = null;
			renderer = null;
			_navigation.leftBtnSide.x += 50;
			_navigation.leftBtnSide.y += 30;
			hslSliders.onDisabled();
			brushStyleUI.onDisabled();
			photoStyleUI.onDisabled();
			colorPalette.removeEventListener("Show Source", onShowSource );
			colorPalette.removeEventListener("Hide Source", onHideSource );
		}
		
		protected function onPreviewMixtureChanged(event:Event):void
		{
			var value:Number = _userPaintSettings.previewMixtureParameter.numberValue;
			renderer.sourceTextureAlpha = value < 0.5 ? 1 : 1 - ( value - 0.5 ) / 0.5;
			renderer.paintAlpha = value > 0.5 ? 1 : value / 0.5;
		}
		
		protected function onBlendParameterChanged(event:Event):void
		{
			notifyColorStyleChangedSignal.dispatch( _userPaintSettings.styleMatrices[ _userPaintSettings.colorStyleParameter.index],_userPaintSettings.styleBlendParameter.numberValue);
		}
		
		protected function onStyleParameterChanged(event:Event):void
		{
			notifyColorStyleChangedSignal.dispatch( _userPaintSettings.styleMatrices[ _userPaintSettings.colorStyleParameter.index],_userPaintSettings.styleBlendParameter.numberValue);
		}
		
		override protected function onEnabled():void
		{
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK_SLIM, false );
			_navigation.leftBtnSide.x -= 50;
			_navigation.leftBtnSide.y -= 30;
			setBgType( NavigationBg.BG_TYPE_WOOD );
			setHeader("Paint Settings");
			hslSliders.onEnabled();
			brushStyleUI.onEnabled();
			photoStyleUI.onEnabled();
			updateContextUI();
			brushStyleUI.setParameters(styleParameter,slider1Parameter,slider2Parameter);
			photoStyleUI.setParameters(_userPaintSettings.colorStyleParameter,_userPaintSettings.styleBlendParameter,_userPaintSettings.previewMixtureParameter);
			colorPalette.addEventListener("Show Source", onShowSource );
			colorPalette.addEventListener("Hide Source", onHideSource );
				
		}
		
		
		
		public function setCurrentColor( newColor:uint, colorMode:int, fromSliders:Boolean ):void
		{
			if ( !fromSliders )
			{
				colorPalette.autoColor = (colorMode == PaintMode.PHOTO_MODE);
				hslSliders.updateSliders();
				
			} else {
				if ( colorPalette.pipetteSwatchSelected ) notifyChangePipetteColorSignal.dispatch(newColor)
				colorPalette.autoColor = false;
				colorPalette.selectedColor = newColor;
				_userPaintSettings.setColorMode(PaintMode.COLOR_MODE);
			}
			if (!colorPalette.autoColor && _userPaintSettings.selectedSwatchIndex > -1 && colorPalette.selectedColor != newColor ) colorPalette.selectedIndex = -1;
			
			updateContextUI();
		}
		
		public function updateContextUI():void
		{
			if ( _userPaintSettings.colorMode == PaintMode.COLOR_MODE )
			{
				hslSliders.visible = true;
				photoStyleUI.visible = false;
				colorPalette.visible = true;
			} else if ( _userPaintSettings.colorMode == PaintMode.PHOTO_MODE || _userPaintSettings.colorMode == PaintMode.ERASER_MODE){
				hslSliders.visible = false;
				photoStyleUI.showStyleUI(true);
				photoStyleUI.visible = true;
				colorPalette.visible = true;
			}else if ( _userPaintSettings.colorMode == PaintMode.COSMETIC_MODE ){
				hslSliders.visible = false;
				photoStyleUI.showStyleUI(false);
				photoStyleUI.visible = true;
				colorPalette.visible = false;
			}
		}
		
		public function canChargePipette():Object
		{
			if ( colorPalette.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				var swatch:Sprite = colorPalette.getSwatchUnderMouse( false );
				if ( swatch != null )
				{
					
					if ( !(colorPalette.isAutoColorSwatch( swatch ) || colorPalette.isPipetteSwatch( swatch )))
					{
						selectedPipetteChargeSwatch = swatch;
						var rgb:uint = swatch.transform.colorTransform.color; 
						currentSwatchMixRed = (rgb >> 16) & 0xff;
						currentSwatchMixGreen= (rgb >> 8) & 0xff;
						currentSwatchMixBlue = rgb & 0xff;
						blendFactor = 0.005;
						blendFactorIncrease = 1.0175;
						return {canCharge:true, color:rgb, pos:new Point(colorPalette.x + swatch.x,colorPalette.y + swatch.y - 32)};
					} 
				}
			} 
			selectedPipetteChargeSwatch = null;
			return {canCharge:false};
			
		}
		
		public function set userPaintSettings(value:UserPaintSettingsModel):void
		{
			_userPaintSettings = value;
			hslSliders.userPaintSettings = value;
		}
		
		public function onPipetteCharging( pipette:Pipette ):void
		{
			colorPalette.changeCurrentColorSwatch( pipette.currentColor );
		}

		public function onPipetteDischarging( pipette:Pipette ):void
		{
			if (!selectedPipetteChargeSwatch) return;
			
			currentSwatchMixRed   = pipette.pipette_red   * blendFactor + currentSwatchMixRed   * (1- blendFactor);
			currentSwatchMixGreen = pipette.pipette_green * blendFactor + currentSwatchMixGreen * (1- blendFactor);
			currentSwatchMixBlue  = pipette.pipette_blue  * blendFactor + currentSwatchMixBlue  * (1- blendFactor);
			blendFactor *= blendFactorIncrease;
			if ( blendFactor > 1 ) blendFactor = 1;
			if ( currentSwatchMixRed < 0 ) currentSwatchMixRed = 0;
			else if ( currentSwatchMixRed > 255 ) currentSwatchMixRed = 255;
			if ( currentSwatchMixGreen < 0 ) currentSwatchMixGreen = 0;
			else if ( currentSwatchMixGreen > 255 ) currentSwatchMixGreen = 255;
			if ( currentSwatchMixBlue < 0 ) currentSwatchMixBlue = 0;
			else if (currentSwatchMixBlue > 255 ) currentSwatchMixBlue = 255;
			
			colorPalette.changeSwatchColor( selectedPipetteChargeSwatch, currentSwatchMixRed << 16 | currentSwatchMixGreen << 8 | currentSwatchMixBlue );
		}
		
		public function setParameters( parameterSetVO:ParameterSetVO ):void {
			
			_parameterSetVO = parameterSetVO;
			trace( this, "receiving parameters for brush " + parameterSetVO.brushName + ", with num parameters: " + parameterSetVO.parameters.length );
			
			var list:Vector.<PsykoParameter> = _parameterSetVO.parameters;
			var numParameters:uint = list.length;
			
			
			
			
			for( var i:uint = 0; i < numParameters; ++i ) 
			{
				var parameter:PsykoParameter = list[ i ];
				var data:ButtonData;
				if( (parameter.type == PsykoParameter.IntParameter
					|| parameter.type == PsykoParameter.NumberParameter
					|| parameter.type == PsykoParameter.AngleParameter) ){
					if ( parameter.showInUI == 1 ) slider1Parameter = parameter;
					if ( parameter.showInUI == 2 ) slider2Parameter = parameter;
				} else if (styleParameter==null && parameter.type == PsykoParameter.IconListParameter &&  parameter.showInUI == 0)
				{
					styleParameter = parameter;
				}
			}
			
			
		}
		
		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}
		
		
		private function positionUiElement( element:DisplayObject, offsetX:Number = 0, offsetY:Number = 0 ):void {
			element.x = 1024 / 2 - element.width / 2 + offsetX;
			element.y = UI_ELEMENT_Y + offsetY;
		}
		
		
		public function onShowSource(event:Event):void
		{
			previousRendererSourceTextureAlpha = renderer.sourceTextureAlpha;
			previousRendererPaintAlpha = renderer.paintAlpha;
			renderer.sourceTextureAlpha = 1;
			renderer.paintAlpha = 0.01;
			sourcePreviewActive = true;
		}
		
		public function onHideSource(event:Event):void
		{
			if ( sourcePreviewActive )
			{
				renderer.sourceTextureAlpha = previousRendererSourceTextureAlpha;
				renderer.paintAlpha = previousRendererPaintAlpha ;
				sourcePreviewActive = false;
			}
		}
	}
}