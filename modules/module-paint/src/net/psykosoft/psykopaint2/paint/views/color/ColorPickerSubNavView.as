package net.psykosoft.psykopaint2.paint.views.color
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
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
	import net.psykosoft.psykopaint2.paint.configuration.ColorStylePresets;
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
		
		private var colorStyleParameter:PsykoParameter;
		private var styleBlendParameter:PsykoParameter;
		private var previewMixtureParameter:PsykoParameter;
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;
		
		private var styleMatrices:Vector.<Vector.<Number>>;
		
		public function ColorPickerSubNavView()
		{
			super();
		}
		
		override public function setup():void
		{
			super.setup();
			
			brushStyleUI.setup(1,2);
			hslSliders.setup();
			photoStyleUI = new StyleUI();
			photoStyleUI.x = hslSliders.x - 32;
			photoStyleUI.y = brushStyleUI.y;
			photoStyleUI.setup(3,4);
			addChild(photoStyleUI);
			photoStyleUI.visible = false;
			
			colorStyleParameter = new PsykoParameter( PsykoParameter.IconListParameter,"Color Style",0,["No Style","Contrast Style","Black and White Style","Supersaturated Style","Mona Lisa Style","William Turner Style","Miro Style","Picasso Style"]);
			styleBlendParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Style Blend Factor",1,0,1);
			previewMixtureParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Preview Blending",0.5,0,1);
			
			colorStyleParameter.addEventListener(Event.CHANGE, onStyleParameterChanged );
			styleBlendParameter.addEventListener(Event.CHANGE, onBlendParameterChanged );
			previewMixtureParameter.addEventListener(Event.CHANGE,onPreviewMixtureChanged );
			
			photoStyleUI.setParameters(colorStyleParameter,styleBlendParameter,previewMixtureParameter);
			
			
			//this must be called at the end since it will trigger color change signals
			colorPalette.setUserPaintSettings( _userPaintSettings );
		}
		
		protected function onPreviewMixtureChanged(event:Event):void
		{
			var value:Number = previewMixtureParameter.numberValue;
			renderer.sourceTextureAlpha = value < 0.5 ? 1 : 1 - ( value - 0.5 ) / 0.5;
			renderer.paintAlpha = value > 0.5 ? 1 : value / 0.5;
		}
		
		protected function onBlendParameterChanged(event:Event):void
		{
			notifyColorStyleChangedSignal.dispatch(styleMatrices[ colorStyleParameter.index],styleBlendParameter.numberValue);
		}
		
		protected function onStyleParameterChanged(event:Event):void
		{
			notifyColorStyleChangedSignal.dispatch(styleMatrices[ colorStyleParameter.index],styleBlendParameter.numberValue);
		}
		
		override protected function onEnabled():void
		{
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK_SLIM, false );
			_navigation.leftBtnSide.x -= 50;
			_navigation.leftBtnSide.y -= 30;
			setBgType( NavigationBg.BG_TYPE_WOOD );
			hslSliders.onEnabled();
			brushStyleUI.onEnabled();
			photoStyleUI.onEnabled();
			updateContextUI();
			
		}
		
		override protected function onDisabled():void
		{
			_navigation.leftBtnSide.x += 50;
			_navigation.leftBtnSide.y += 30;
			hslSliders.onDisabled();
			brushStyleUI.onDisabled();
			photoStyleUI.onDisabled();
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
		
		private function updateContextUI():void
		{
			if ( _userPaintSettings.colorMode == PaintMode.COLOR_MODE )
			{
				hslSliders.visible = true;
				photoStyleUI.visible = false;
			} else {
				hslSliders.visible = false;
				photoStyleUI.visible = true;
			}
		}
		
		public function canChargePipette():Object
		{
			if ( colorPalette.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				var swatch:Sprite = colorPalette.getSwatchUnderMouse( false );
				if ( swatch != null )
				{
					var isAutoColor:Boolean;
					if ( !(( isAutoColor = colorPalette.isAutoColorSwatch( swatch )) || colorPalette.isPipetteSwatch( swatch )))
					{
						selectedPipetteChargeSwatch = swatch;
						var rgb:uint = swatch.transform.colorTransform.color; 
						currentSwatchMixRed = (rgb >> 16) & 0xff;
						currentSwatchMixGreen= (rgb >> 8) & 0xff;
						currentSwatchMixBlue = rgb & 0xff;
						blendFactor = 0.005;
						blendFactorIncrease = 1.0175;
						return {canCharge:true, color:rgb, pos:new Point(colorPalette.x + swatch.x,colorPalette.y + swatch.y - 32)};
					} else if ( isAutoColor ){
						
						previousRendererSourceTextureAlpha = renderer.sourceTextureAlpha;
						previousRendererPaintAlpha = renderer.paintAlpha;
						renderer.sourceTextureAlpha = 1;
						renderer.paintAlpha = 0.01;
						sourcePreviewActive = true;
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
			var styleParameter:PsykoParameter;
			var slider1Parameter:PsykoParameter;
			var slider2Parameter:PsykoParameter;
			
			for( var i:uint = 0; i < numParameters; ++i ) 
			{
				var parameter:PsykoParameter = list[ i ];
				var data:ButtonData;
				if( (parameter.type == PsykoParameter.IntParameter
					|| parameter.type == PsykoParameter.NumberParameter
					|| parameter.type == PsykoParameter.AngleParameter) ){
					if (slider1Parameter == null )
						slider1Parameter = parameter;
					else if (slider2Parameter == null )
						slider2Parameter = parameter;
				} else if (styleParameter==null && parameter.type == PsykoParameter.IconListParameter )
				{
					styleParameter = parameter;
				}
			}
			brushStyleUI.setParameters(styleParameter,slider1Parameter,slider2Parameter);
		}
		
		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}
		
		
		private function positionUiElement( element:DisplayObject, offsetX:Number = 0, offsetY:Number = 0 ):void {
			element.x = 1024 / 2 - element.width / 2 + offsetX;
			element.y = UI_ELEMENT_Y + offsetY;
		}
		
		public function onLongTapGestureEnded():void
		{
			if ( sourcePreviewActive )
			{
				renderer.sourceTextureAlpha = previousRendererSourceTextureAlpha;
				renderer.paintAlpha = previousRendererPaintAlpha ;
				sourcePreviewActive = false;
			}
		}
		
		public function setColorTransfer(colorTransfer:ColorTransfer):void
		{
			styleMatrices = new Vector.<Vector.<Number>>();
			//var cm:ColorMatrix = new ColorMatrix();
			styleMatrices.push(null);
			
			
			var presets:Vector.<String> = ColorStylePresets.getAvailableColorStylePresets();
			var cm:ColorMatrix;
			for ( var i:int = 0; i < presets.length; i++ )
			{
				var preset:XML = ColorStylePresets.getPreset(presets[i]);
				colorTransfer.setFactors(0, preset );
				colorTransfer.calculateColorMatrices();
				cm = colorTransfer.getColorMatrix(0);
				var v:Vector.<Number> = Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]);
				cm = colorTransfer.getColorMatrix(1);
				v.push(cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255);
				var blendIn:Number = preset.@blend_in;
				var blendOut:Number =  preset.@blend_out;
				var blendRange:Number = blendIn + blendOut;
				var threshold:Number = colorTransfer.getThreshold(blendIn,blendOut);
				v.push((threshold - blendRange *0.5 )/ 255.0 ,  255 / blendRange );
				styleMatrices.push( v );
				
			}
			
			/*
			cm.adjustContrast(10);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.desaturate();
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.adjustSaturation(4);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			*/
			
		}
	}
}