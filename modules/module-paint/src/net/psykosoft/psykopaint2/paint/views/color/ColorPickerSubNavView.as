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
		
		public var slider1Handle:Sprite;
		public var slider2Handle:Sprite;
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
		
		private var hueMap:BitmapData;
		private var satMap:BitmapData;
		private var lightnessMap:BitmapData;
		
		private var hueMapHolder:Bitmap;
		private var satMapHolder:Bitmap;
		private var lightnessMapHolder:Bitmap;
		
		private var hslSliderHolder:Sprite;
		
		private var activeHSLSliderIndex:int;
		private var HSLSliderPaddingLeft:Number = 16;
		private var HSLSliderPaddingRight:Number = 16;
		private var HSLSliderRange:Number = 255 - HSLSliderPaddingLeft - HSLSliderPaddingRight;
		private var HSLSliderOffset:int = - 14;
		
		private var sliderPaddingLeft:Number = 16;
		private var sliderPaddingRight:Number = 16;
		private var sliderRange:Number = 255 - sliderPaddingLeft - sliderPaddingRight;
		private var sliderOffset:int = 32;
		
		
		private var saturationSliderValues:Array;
		
		
		private var currentSwatchMixRed:Number;
		private var currentSwatchMixGreen:Number;
		private var currentSwatchMixBlue:Number;
		
		private var selectedPipetteChargeSwatch:Sprite;
		private var activeSliderIndex:int;
		
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
			slider2Handle.mouseEnabled = false;
			lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			saturationOverlay.mouseEnabled = false;
			lightnessOverlay.mouseEnabled = false;
			
			styleBar.addEventListener(MouseEvent.MOUSE_DOWN, onStyleMouseDown );
			slider1Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider1MouseDown );
			slider2Bar.addEventListener(MouseEvent.MOUSE_DOWN, onSlider2MouseDown );
			
			
			colorPalette.setUserPaintSettings( _userPaintSettings );
			
		}
		
		override protected function onEnabled():void
		{
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			
			setBgType( NavigationBg.BG_TYPE_WOOD );
		}
		
		
		protected function onStyleMouseDown( event:MouseEvent ):void
		{
			if ( styleBar.mouseX < sliderOffset  || styleBar.mouseX > 256 + sliderOffset  || styleBar.mouseY < 0 || styleBar.mouseY > 69) return;
			
			styleSelector.x = sliderOffset + styleBar.x + int((styleBar.mouseX - sliderOffset ) / 60) * 60;
		}
		
		protected function onSlider1MouseDown( event:MouseEvent ):void
		{
			if ( slider1Bar.mouseX < 0 || slider1Bar.mouseX > 256 || slider1Bar.mouseY < 0 || slider1Bar.mouseY > 69) return;
			activeSliderIndex = 0;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
		}
		
		protected function onSlider2MouseDown( event:MouseEvent ):void
		{
			if ( slider2Bar.mouseX < 0 || slider2Bar.mouseX > 256 || slider2Bar.mouseY < 0 || slider2Bar.mouseY > 69) return;
			activeSliderIndex = 1;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
		}
		
		protected function onSliderMouseMove( event:MouseEvent ):void
		{
			var sx:Number = slider1Bar.mouseX / sliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			switch ( activeSliderIndex )
			{
				case 0: //hue
					slider1Handle.x = sliderOffset + slider1Bar.x  + sliderPaddingLeft + sx * sliderRange;
					break;
				case 1: //sat
					slider2Handle.x = sliderOffset + slider2Bar.x  + sliderPaddingLeft + sx * sliderRange;
					break;
			}
			
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
			
			// Create a center button for each parameter, with a local listener.
			// Specific parameter ui components will show up when clicking on a button.
			
			invalidateCenterButtons();
			
			var list:Vector.<PsykoParameter> = _parameterSetVO.parameters;
			var numParameters:uint = list.length;
			
			for( var i:uint = 0; i < numParameters; ++i ) {
				
				var parameter:PsykoParameter = list[ i ];
				
				trace( this, "adding parameter with id: " + parameter.id + ", and label: " + parameter.label );
				
				if( parameter.type != PsykoParameter.ColorParameter ) {
					if( parameter.id != CUSTOM_COLOR_ID ) {
						
						//TODO: handling the custom color switch this way is not really ideal but it has to do for now
						
						var data:ButtonData = createCenterButton( parameter.id, parameter.label, ButtonIconType.DEFAULT, null, null, false, true, true, MouseEvent.MOUSE_DOWN );
						
						// Button slider?
						if( parameter.type == PsykoParameter.IntParameter
							|| parameter.type == PsykoParameter.NumberParameter
							|| parameter.type == PsykoParameter.AngleParameter ) {
							data.itemRendererType = SliderButton;
							data.minValue = parameter.minLimit;
							data.maxValue = parameter.maxLimit;
							data.value = parameter.type == PsykoParameter.AngleParameter ? parameter.degrees : parameter.numberValue;
							data.previewID = parameter.previewID;
							data.onItemRendererAssigned = onSliderButtonRendererAssigned;
							data.onItemRendererReleased = onSliderButtonRendererReleased;
						} else if ( parameter.type == PsykoParameter.IconListParameter )
						{
							data.itemRendererType = SliderButton;
							data.minValue = parameter.minLimit;
							data.maxValue = parameter.maxLimit;
							data.value = parameter.index;
							data.previewID = parameter.previewID;
							data.onItemRendererAssigned = onSliderButtonRendererAssigned;
							data.onItemRendererReleased = onSliderButtonRendererReleased;
							
						}
					}
				}
				//else {
				//	showRightButton( true );
				//}
				
				
			}
			
			validateCenterButtons();
		}
		
		private function onSliderButtonRendererAssigned( renderer:SliderButton ):void {
			//			trace( this, "onSliderButtonRendererAssigned - id: " + renderer.id );
			renderer.addEventListener( Event.CHANGE, onSliderButtonChanged );
			renderer.addEventListener( MouseEvent.MOUSE_DOWN, onSliderButtonMouseDown );
		}
		
		private function onSliderButtonRendererReleased( renderer:SliderButton ):void {
			//			trace( this, "onSliderButtonRendererReleased - id: " + renderer.id );
			renderer.removeEventListener( Event.CHANGE, onSliderButtonChanged );
			renderer.removeEventListener( MouseEvent.MOUSE_DOWN, onSliderButtonMouseDown );
		}
		
		private function onSliderButtonMouseDown( event:MouseEvent ):void {
			// Always on top.
			var slider:SliderButton = ClickUtil.getObjectOfClassInHierarchy( event.target as DisplayObject, SliderButton ) as SliderButton;
			slider.parent.swapChildren( slider, slider.parent.getChildAt( slider.parent.numChildren - 1 ) );
		}
		
		public function updateParameters( parameterSetVO:ParameterSetVO ):void {
			_parameterSetVO = parameterSetVO;
		}
		
		private function onSliderButtonChanged( event:Event ):void {
			var slider:SliderButton = event.target as SliderButton;
			//			trace( this, "onSliderButtonChanged: " + slider.labelText );
			if ( _parameter )
			{
				//focusOnParameterWithId( slider.id );
				if ( _parameter.type == PsykoParameter.IconListParameter )
				{
					_parameter.index = slider.value;
					slider.labelText = _parameter.stringValue;
				} else {
					_parameter.value = slider.value;
					slider.updateLabelFromValue();
				}
			} else {
				trace("ERRROR - something is not right with the parameter in EditBrushSubNavView");
			}
		}
		
		/* called by the mediator */
		public function openParameterWithId( id:String ):void {
			
			trace( this, "opening parameter for id: " + id );
			
			closeLastParameter();
			_uiElements = new Vector.<DisplayObject>();
			
			focusOnParameterWithId( id );
			if( _parameter == null ) return;
			
			var parameterType:int = _parameter.type;
			
			var i:uint;
			var slider:SliderBase;
			
			// Simple slider.
			if( parameterType == PsykoParameter.IntParameter || parameterType == PsykoParameter.NumberParameter ) {
				// Replaced by slider buttons on setParameters().
				/*slider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.numberValue;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );*/
			}
				
				// Range slider.
			else if( parameterType == PsykoParameter.IntRangeParameter || parameterType == PsykoParameter.NumberRangeParameter ) {
				throw("Range Slider has been deprecated - use something else");
				/*
				var rangeSlider:RangedSlider = new RangedSlider();
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerRangeValue;
				rangeSlider.value2 = _parameter.upperRangeValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
				*/
			}
				
				
			else if( parameterType == PsykoParameter.AngleRangeParameter ) {
				throw("Range Slider has been deprecated - use something else");
				/*
				rangeSlider = new RangedSlider();
				rangeSlider.labelMode = RangedSlider.LABEL_DEGREES;
				rangeSlider.minValue = _parameter.minLimit;
				rangeSlider.maxValue = _parameter.maxLimit;
				rangeSlider.value1 = _parameter.lowerDegreesValue;
				rangeSlider.value2 = _parameter.upperDegreesValue;
				rangeSlider.addEventListener( Event.CHANGE, onRangeSliderChanged );
				rangeSlider.setWidth( 451 );
				positionUiElement( rangeSlider );
				addChild( rangeSlider );
				_uiElements.push( rangeSlider );
				*/
			}
				
				// Angle.
			else if( parameterType == PsykoParameter.AngleParameter ) {
				
				//sorry, but unfortunately knob is pretty unusable right now, replaced it with regular slider
				/*
				var knob:Knob = new Knob( this );
				knob.value = _parameter.degrees;
				knob.minimum = _parameter.minLimit;
				knob.maximum = _parameter.maxLimit;
				knob.addEventListener( Event.CHANGE, onKnobChanged );
				knob.draw();
				positionUiElement( knob as DisplayObject, 0, -20 );
				_uiElements.push( knob );
				*/
				
				// Replaced by slider buttons on setParameters().
				/*slider = new SbSlider();
				slider.minValue = _parameter.minLimit;
				slider.maxValue = _parameter.maxLimit;
				slider.value = _parameter.degrees;
				slider.labelMode = SbRangedSlider.LABEL_DEGREES;
				slider.addEventListener( Event.CHANGE, onSliderChanged );
				slider.setWidth( 276 );
				positionUiElement( slider );
				addChild( slider );
				_uiElements.push( slider );*/
			}
				
				// Combo box.
			else if( parameterType == PsykoParameter.StringListParameter) {
				// || parameterType == PsykoParameter.IconListParameter 
				var list:Vector.<String> = _parameter.stringList;
				var len:uint = list.length;
				var combobox:ComboboxView = new ComboboxView();
				combobox.interactionStartedSignal.add( onComboboxInteractionStarted );
				combobox.interactionEndedSignal.add( onComboboxInteractionEnded );
				for( i = 0; i < len; ++i ) {
					combobox.addItem( { label: list[ i ] } );
				}
				combobox.selectedIndex = _parameter.index;
				addChild( combobox );
				combobox.addEventListener( Event.CHANGE, onComboBoxChanged );
				positionUiElement( combobox as DisplayObject, 40, 10 );
				_uiElements.push( combobox );
			}
				
				// Check box
			else if( parameterType == PsykoParameter.BooleanParameter ) {
				var checkBox:CheckBox = new CheckBox();
				checkBox.selected = _parameter.booleanValue;
				checkBox.addEventListener( Event.CHANGE, onCheckBoxChanged );
				positionUiElement( checkBox );
				addChild( checkBox );
				_uiElements.push( checkBox );
			}
				// No Ui component for this parameter.
			else if (parameterType == PsykoParameter.IconListParameter)
			{
				
			} else {
				trace( this, "*** Warning *** - parameter type not supported: " + PsykoParameter.getTypeName( parameterType ) );
				var tf:TextField = new TextField();
				tf.selectable = tf.mouseEnabled = false;
				tf.text = "parameter type not supported: " + PsykoParameter.getTypeName( parameterType );
				tf.width = tf.textWidth * 1.2;
				tf.height = tf.textHeight * 1.2;
				positionUiElement( tf );
				addChild( tf );
				_uiElements.push( tf );
			}
		}
		
		private function focusOnParameterWithId( id:String ):void {
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
		
		private function closeLastParameter():void {
			
			if( !_uiElements ) return;
			
			// Remove all ui elements from display and clear listeners
			var len:uint = _uiElements.length;
			for( var i:uint; i < len; ++i ) {
				var uiElement:DisplayObject = _uiElements[ i ];
				if( uiElement is SliderBase ) uiElement.removeEventListener( Event.CHANGE, onSliderChanged );
				else if( uiElement is ComboBox ) {
					uiElement.removeEventListener( Event.SELECT, onComboBoxChanged );
				}
				else if( uiElement is CheckBox ) uiElement.removeEventListener( Event.CHANGE, onCheckBoxChanged );
				else if( uiElement is Knob ) uiElement.removeEventListener( Event.CHANGE, onKnobChanged );
				else {
					trace( this, "*** Warning *** - don't know how to clean up ui element: " + uiElement );
				}
				//else if( uiElement is RangedSlider ) uiElement.removeEventListener( Event.CHANGE, onRangeSliderChanged );
				removeChild( uiElement );
			}
			_uiElements = null;
		}
		
		private function onKnobChanged( event:Event ):void {
			var knob:Knob = event.target as Knob;
			_parameter.degrees = knob.value;
		}
		
		private function onCheckBoxChanged( event:Event ):void {
			var checkBox:CheckBox = event.target as CheckBox;
			_parameter.booleanValue = checkBox.selected;
		}
		
		private function onComboBoxChanged( event:Event ):void {
			var comboBox:ComboboxView = event.target as ComboboxView;
			_parameter.index = comboBox.selectedIndex;
		}
		
		private function onComboboxInteractionEnded():void {
			GestureManager.gesturesEnabled = true;
		}
		
		private function onComboboxInteractionStarted():void {
			GestureManager.gesturesEnabled = false;
		}
		
		private function onSliderChanged( event:Event ):void {
			var slider:SliderBase = event.target as SliderBase;
			_parameter.value = slider.value;
		}
		
		private function positionUiElement( element:DisplayObject, offsetX:Number = 0, offsetY:Number = 0 ):void {
			element.x = 1024 / 2 - element.width / 2 + offsetX;
			element.y = UI_ELEMENT_Y + offsetY;
		}
	}
}