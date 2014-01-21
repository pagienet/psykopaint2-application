package net.psykosoft.psykopaint2.paint.views.color
{
	
	import com.bit101.components.ComboBox;
	import com.bit101.components.Knob;
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.components.combobox.ComboboxView;
	import net.psykosoft.psykopaint2.core.views.components.previews.BrushStylePreview;
	import net.psykosoft.psykopaint2.core.views.components.slider.SliderBase;
	import net.psykosoft.psykopaint2.core.views.components.slider.SliderButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	
	import org.osflash.signals.Signal;
	
	public class ColorPickerSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		
		private var _uiElements:Vector.<DisplayObject>;
		private var _parameterSetVO:ParameterSetVO;
		private var _parameter:PsykoParameter;
		
		public static const CUSTOM_COLOR_ID:String = "Custom Color";
		private const UI_ELEMENT_Y:uint = 320;

		private var _userPaintSettings:UserPaintSettingsModel;
		
		public var slider1Handle:MovieClip;
		public var slider2Handle:MovieClip;
		public var slider1Bar:Sprite;
		public var slider2Bar:Sprite;
		public var styleBar:Sprite;
		public var styleSelector:Sprite;
		
		public var hueHandle:MovieClip;
		public var saturationHandle:MovieClip;
		public var lightnessHandle:MovieClip;
		public var sliderBackdrop:Sprite;
		
		public var hueOverlay:Sprite;
		public var saturationOverlay:Sprite;
		public var lightnessOverlay:Sprite;
		
		public var colorPalette:ColorPalette;
		
		private var styleIconHolder:Sprite;
		
		private var hueMap:BitmapData;
		private var satMap:BitmapData;
		private var lightnessMap:BitmapData;
		
		private var hueMapHolder:Bitmap;
		private var satMapHolder:Bitmap;
		private var lightnessMapHolder:Bitmap;
		
		private var hslSliderHolder:Sprite;
		
		private var activeHSLSliderIndex:int;
		private var HSLSliderPaddingLeft:Number = 16;
		private var HSLSliderRange:Number = 239 - HSLSliderPaddingLeft;
		private var HSLSliderOffset:int = - 14;
		
		private var sliderPaddingLeft:Number = 40;
		private var sliderRange:Number = 277 - sliderPaddingLeft;
		private var sliderOffset:int = 42;
		
		private var saturationSliderValues:Array;
		
		private var currentSwatchMixRed:Number;
		private var currentSwatchMixGreen:Number;
		private var currentSwatchMixBlue:Number;
		
		private var selectedPipetteChargeSwatch:Sprite;
		private var activeSliderIndex:int;
		
		private var uiParameters:Vector.<PsykoParameter>;
		private var styleParameter:PsykoParameter;
		private var previewIcon:BrushStylePreview;
		private var previewDelay:int;
		
		public function ColorPickerSubNavView()
		{
			super();
			_scroller.y -= 200;
		}
		
		override public function setup():void
		{
			super.setup();
			
			
			hueMap = new BitmapData(256,1,false,0);
			satMap = new BitmapData(256,1,false,0);
			lightnessMap = new BitmapData(256,1,false,0);
			generateHueAndLightnessSliders();
			
			hslSliderHolder = new Sprite();
			hslSliderHolder.x = 753;
			hslSliderHolder.y = 599;
			addChildAt(hslSliderHolder,getChildIndex(sliderBackdrop)+1);
			hslSliderHolder.addEventListener(MouseEvent.MOUSE_DOWN, onHSLSliderMouseDown );
			
			
			hueMapHolder = new Bitmap(hueMap,"auto",false);
			hueMapHolder.height = 41;
			hueMapHolder.y = -4;
			hslSliderHolder.addChild(hueMapHolder);
			
			satMapHolder = new Bitmap(satMap,"auto",false);
			satMapHolder.height = 41;
			satMapHolder.y = 55;
			hslSliderHolder.addChild(satMapHolder);
			
			lightnessMapHolder = new Bitmap(lightnessMap,"auto",false);
			lightnessMapHolder.height = 41;
			lightnessMapHolder.y = 55 + 59;
			hslSliderHolder.addChild(lightnessMapHolder);
			
			hueHandle.gotoAndStop(1);
			lightnessHandle.gotoAndStop(1);
			saturationHandle.gotoAndStop(1);
			
			hueHandle.mouseEnabled = false;
			saturationHandle.mouseEnabled = false;
			slider1Handle.mouseEnabled = false;
			slider1Handle.gotoAndStop(1);
			slider2Handle.mouseEnabled = false;
			slider2Handle.gotoAndStop(2);
			lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			saturationOverlay.mouseEnabled = false;
			lightnessOverlay.mouseEnabled = false;
			
			styleBar.addEventListener(MouseEvent.MOUSE_DOWN, onStyleMouseDown );
			slider1Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider1MouseDown );
			slider2Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider2MouseDown );
			
			
			colorPalette.setUserPaintSettings( _userPaintSettings );
			
			styleSelector.mouseEnabled = false;
			
			styleIconHolder = new Sprite();
			styleIconHolder.x = styleBar.x + 40;
			styleIconHolder.y = styleBar.y + 36;
			styleIconHolder.mouseEnabled = false;
			styleIconHolder.mouseChildren = false;
			
			previewIcon = new BrushStylePreview();
			previewIcon.y = -45;
			previewIcon.height = 128;
			previewIcon.scaleX = previewIcon.scaleY;
			addChildAt(styleIconHolder,getChildIndex(styleBar)+1);
			
		}
		
		override protected function onEnabled():void
		{
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK_SLIM, false );
			_navigation.leftBtnSide.x -= 50;
			_navigation.leftBtnSide.y -= 50;
			setBgType( NavigationBg.BG_TYPE_WOOD );
		}
		
		override protected function onDisabled():void
		{
			_navigation.leftBtnSide.x += 50;
			_navigation.leftBtnSide.y += 50;
		}
		
		
		protected function onStyleMouseDown( event:MouseEvent ):void
		{
			if ( styleBar.mouseX < sliderPaddingLeft - 27 || styleBar.mouseX > sliderPaddingLeft + sliderRange + 32 || styleBar.mouseY < 0 || styleBar.mouseY > 60) return;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStyleMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onStyleMouseUp );
			
			previewDelay = setTimeout(showStylePreview,200);
			onStyleMouseMove();
		}
		
		private function showStylePreview():void
		{
			styleBar.addChild(previewIcon);
		}
		
		protected function onStyleMouseMove( event:MouseEvent = null ):void
		{
			
			var sx:Number = (styleBar.mouseX - sliderPaddingLeft) / sliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			previewIcon.x = sx * sliderRange + sliderPaddingLeft;
			
			
			var index:int = sx * (styleParameter.stringList.length - 1) + 0.5;
			
			var spacing:Number = sliderRange / (styleParameter.stringList.length - 1);
			styleSelector.x = sliderOffset + styleBar.x + index * spacing;
			
			styleParameter.index = index;
			previewIcon.showIcon( styleParameter.stringValue );
		}
		
		protected function onStyleMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStyleMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStyleMouseUp );
			if ( styleBar.contains(previewIcon)) styleBar.removeChild(previewIcon);
			clearTimeout(previewDelay);
		}
		
		protected function onSlider1MouseDown( event:MouseEvent ):void
		{
			if ( slider1Bar.mouseX < sliderPaddingLeft - 27 || slider1Bar.mouseX > sliderPaddingLeft + sliderRange + 32 || slider1Bar.mouseY < 5 || slider1Bar.mouseY > 60) return;
			activeSliderIndex = 0;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			onSliderMouseMove();
		}
		
		protected function onSlider2MouseDown( event:MouseEvent ):void
		{
			if ( slider2Bar.mouseX < sliderPaddingLeft - 27 || slider2Bar.mouseX > sliderPaddingLeft + sliderRange + 32 || slider2Bar.mouseY < 5 || slider2Bar.mouseY > 60) return;
			activeSliderIndex = 1;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			onSliderMouseMove();
		}
		
		protected function onSliderMouseMove( event:MouseEvent = null ):void
		{
			var sx:Number = (slider1Bar.mouseX - sliderPaddingLeft) / sliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			switch ( activeSliderIndex )
			{
				case 0: 
					slider1Handle.x = sliderOffset + slider1Bar.x  +  + sx * sliderRange;
					break;
				case 1: 
					slider2Handle.x = sliderOffset + slider2Bar.x  + sx * sliderRange;
					break;
			}
			uiParameters[activeSliderIndex].normalizedValue = sx;
			
		}
		
		protected function onSliderMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
		}
		
		protected function onHSLSliderMouseDown( event:MouseEvent ):void
		{
			if ( hslSliderHolder.mouseX < 0 || hslSliderHolder.mouseX > 256 || hslSliderHolder.mouseY < 0) return;
			activeHSLSliderIndex = hslSliderHolder.mouseY / 59;
			if ( activeHSLSliderIndex > 2 || hslSliderHolder.mouseY % 59 > 41 ) return;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onHSLSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onHSLSliderMouseUp );
			onHSLSliderMouseMove(event);
		}
		
		protected function onHSLSliderMouseMove( event:MouseEvent ):void
		{
			var sx:Number = hslSliderHolder.mouseX / HSLSliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			switch ( activeHSLSliderIndex )
			{
				case 0: //hue
					hueHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;//sliderHolder.x  + sliderPaddingLeft + sx + sliderOffset;
					_userPaintSettings.hue = sx * 359;//359 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					updateSaturationSlider();
					break;
				case 1: //sat
					saturationHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;//sliderHolder.x+ sliderPaddingLeft +  sx + sliderOffset;
					var v:Array = saturationSliderValues[int(255 * sx)]; //saturationSliderValues[int(255 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight))];
					_userPaintSettings.saturation = v[0];
					_userPaintSettings.lightness = v[1];
					break;
				case 2: //lightness
					lightnessHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;//sliderHolder.x+ sliderPaddingLeft + sx + sliderOffset;
					_userPaintSettings.lightness = 100 * sx;//100 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					updateSaturationSlider();
					break;
			}
			_userPaintSettings.updateCurrentColorFromHSV();
		}
		
		protected function onHSLSliderMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHSLSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onHSLSliderMouseUp );
		}
		
		public function setCurrentColor( newColor:uint, colorMode:int, fromSliders:Boolean ):void
		{
			if ( !fromSliders )
			{
				colorPalette.autoColor = (colorMode == PaintMode.PHOTO_MODE);
				updateSaturationSlider();
				hueHandle.x = HSLSliderOffset + hslSliderHolder.x + HSLSliderPaddingLeft + (isNaN( _userPaintSettings.hue ) ? 0 : _userPaintSettings.hue) / 360 * HSLSliderRange;
				saturationHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.saturation / 100 * HSLSliderRange;
				lightnessHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.lightness / 100 * HSLSliderRange;
			} else {
				colorPalette.autoColor = false;
				colorPalette.selectedColor = newColor;
				_userPaintSettings.setColorMode(PaintMode.COLOR_MODE);
			}
			if (!colorPalette.autoColor && _userPaintSettings.selectedSwatchIndex > -1 && colorPalette.selectedColor != newColor ) colorPalette.selectedIndex = -1;
			
		}
		
		protected function updateSaturationSlider():void
		{
			satMap.lock();
			saturationSliderValues = [];
			var hsv:HSV = _userPaintSettings.currentHSV.clone();
			var vdiff:Number = Math.max(20 - hsv.value,0) / 256;
			var vd:Number = 1 / 256; 
			var v:Number = 0;
			for ( var i:int = 0; i < 256; i++ )
			{
				hsv.saturation = 100 * v;
				hsv.value += vdiff;
				saturationSliderValues.push([hsv.saturation,hsv.value]);
				satMap.setPixel(i,0,ColorConverter.HSVtoUINT(hsv));
				v+=vd;
			}
			satMap.unlock();
			
		}
		
		protected function generateHueAndLightnessSliders():void
		{
			hueMap.lock();
			lightnessMap.lock();
			
			var h:HSV = new HSV(0,100,100);
			var vd:Number = 1 / 256; 
			var v:Number = 0;
			for ( var i:int = 0; i < 256; i++ )
			{
				h.hue = 360 * v;
				hueMap.setPixel(i,0,ColorConverter.HSVtoUINT(h));
				lightnessMap.setPixel(i,0,i << 16 | i << 8 | i);
				v+=vd;
			}
			
			hueMap.unlock();
			lightnessMap.unlock()
		}
		
		public function canChargePipette():Object
		{
			if ( colorPalette.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				var swatch:Sprite = colorPalette.getSwatchUnderMouse( true );
				if ( swatch != null )
				{
					selectedPipetteChargeSwatch = swatch;
					var rgb:uint = swatch.transform.colorTransform.color; 
					currentSwatchMixRed = (rgb >> 16) & 0xff;
					currentSwatchMixGreen= (rgb >> 8) & 0xff;
					currentSwatchMixBlue = rgb & 0xff;
					return {canCharge:true, color:rgb, pos:new Point(colorPalette.x + swatch.x,colorPalette.y + swatch.y - 32)};
				}
			} 
			selectedPipetteChargeSwatch = null;
			return {canCharge:false};
			
		}
		
		public function set userPaintSettings(value:UserPaintSettingsModel):void
		{
			_userPaintSettings = value;
		}

		public function onPipetteDischarging( pipette:Pipette ):void
		{
			if (!selectedPipetteChargeSwatch) return;
			
			var blendFactor:Number = 0.005;
			currentSwatchMixRed = pipette.pipette_red * blendFactor + currentSwatchMixRed * ( 1- blendFactor );
			currentSwatchMixGreen = pipette.pipette_green * blendFactor + currentSwatchMixGreen * ( 1- blendFactor );
			currentSwatchMixBlue = pipette.pipette_blue * blendFactor + currentSwatchMixBlue * ( 1- blendFactor );
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
			
			uiParameters = new Vector.<PsykoParameter>();
			styleParameter = null;
			
			var list:Vector.<PsykoParameter> = _parameterSetVO.parameters;
			var numParameters:uint = list.length;
			for( var i:uint = 0; i < numParameters; ++i ) {
				
				var parameter:PsykoParameter = list[ i ];
				var data:ButtonData;
				if( uiParameters.length < 2 && 
					(parameter.type == PsykoParameter.IntParameter
					|| parameter.type == PsykoParameter.NumberParameter
					|| parameter.type == PsykoParameter.AngleParameter) ) {
					uiParameters.push(parameter);
					if ( uiParameters.length == 1 )
						slider1Handle.x = sliderOffset + slider1Bar.x  + parameter.normalizedValue * sliderRange;
					else 
						slider2Handle.x = sliderOffset + slider2Bar.x  + parameter.normalizedValue * sliderRange;
					
				} else if (styleParameter==null && parameter.type == PsykoParameter.IconListParameter )
				{
					styleParameter = parameter;
					showStyleIcons(parameter);
					var spacing:Number = sliderRange / (styleParameter.stringList.length - 1);
					styleSelector.x = sliderOffset + styleBar.x + styleParameter.index * spacing;
					
				}
			}
		}
		
		private function showStyleIcons(parameter:PsykoParameter):void
		{
			while( styleIconHolder.numChildren > 0 ) styleIconHolder.removeChildAt(0);
			var styleIds:Vector.<String> = parameter.stringList;
			for (var i:int = 0; i< styleIds.length; i++ )
			{
				var preview:BrushStylePreview = new BrushStylePreview();
				preview.showIcon(styleIds[i]);
				preview.height = 48;
				preview.scaleX = preview.scaleY;
				preview.x = (sliderRange / (styleIds.length - 1)) * i;
				styleIconHolder.addChild( preview );
			}
			
		}
		
		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}
		
		public function openParameterWithId( id:String ):void {
			_parameter = null;
			var numParameters:uint = _parameterSetVO.parameters.length;
			for( var i:uint = 0; i < numParameters; i++ ) {
				var parameter:PsykoParameter = _parameterSetVO.parameters[ i ];
				if( parameter.id == id ) {
					_parameter = parameter;
					break;
				}
			}
			trace( this, "focused on parameter: " + _parameter );
		}
		
		
		private function positionUiElement( element:DisplayObject, offsetX:Number = 0, offsetY:Number = 0 ):void {
			element.x = 1024 / 2 - element.width / 2 + offsetX;
			element.y = UI_ELEMENT_Y + offsetY;
		}
	}
}