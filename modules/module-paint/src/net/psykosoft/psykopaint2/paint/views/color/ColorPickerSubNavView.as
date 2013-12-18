package net.psykosoft.psykopaint2.paint.views.color
{
	
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	
	import org.osflash.signals.Signal;
	
	public class ColorPickerSubNavView extends SubNavigationViewBase
	{
		public var currentColorSwatch:Sprite;
		public var hueHandle:MovieClip;
		public var saturationHandle:MovieClip;
		public var lightnessHandle:MovieClip;
		public var sliderBackdrop:Sprite;
		
		public var hueOverlay:Sprite;
		public var saturationOverlay:Sprite;
		public var lightnessOverlay:Sprite;
		
		public var colorPalette:ColorPalette;
		public var colorChangedSignal:Signal;
		public var currentColor:uint = 0;
		public var currentHSV:HSV;
		private var colorMixer:Colormixer;
		//private var colorMixer:FluidColorMixer;
		//private var colorMixer:ColorMixerTDSI;
		private var hueMap:BitmapData;
		private var satMap:BitmapData;
		private var lightnessMap:BitmapData;
		
		private var hueMapHolder:Bitmap;
		private var satMapHolder:Bitmap;
		private var lightnessMapHolder:Bitmap;
		
		private var sliderHolder:Sprite;
		
		private var activeSliderIndex:int;
		private var sliderPaddingLeft:Number = 16;
		private var sliderPaddingRight:Number = 16;
		private var saturationSliderValues:Array;
		private var sliderOffset:int = - 14;
		private var pipette:Pipette;
		
		/*
		private var hueHandleBg:Shape;
		
		private var saturationHandleBg:Shape;
		
		private var lightnessHandleBg:Shape;
		*/
		
		public static const ID_BACK:String = "Back";
		private var pipetteDropSize:int;
		private var currentSwatchMixRed:Number;
		private var currentSwatchMixGreen:Number;
		private var currentSwatchMixBlue:Number;
		
		public function ColorPickerSubNavView()
		{
			super();
			colorChangedSignal = new Signal();
		}
		
		override public function setup():void
		{
			super.setup();
			
			colorPalette.addEventListener( Event.CHANGE, onPaletteColorChanged );
			
			colorMixer = new Colormixer( colorPalette.currentPalette );
			colorMixer.y = 595;
			colorMixer.x = 3;
			colorMixer.addEventListener( Event.CHANGE, onMixerColorPicked );
			colorMixer.blendMode = "multiply";
			addChildAt(colorMixer,getChildIndex(colorPalette));
			
			var mixerMap:BitmapData = new BitmapData(270,190,false,0);
			
			hueMap = new BitmapData(256,1,false,0);
			satMap = new BitmapData(256,1,false,0);
			lightnessMap = new BitmapData(256,1,false,0);
			generateHueAndLightnessSliders();
			
			currentHSV = new HSV(0,0,0);
			
			sliderHolder = new Sprite();
			sliderHolder.x = 753;
			sliderHolder.y = 599;
			addChildAt(sliderHolder,getChildIndex(sliderBackdrop)+1);
			sliderHolder.addEventListener(MouseEvent.MOUSE_DOWN, onSliderMouseDown );
			
			
			hueMapHolder = new Bitmap(hueMap,"auto",false);
			hueMapHolder.height = 41;
			sliderHolder.addChild(hueMapHolder);
			
			satMapHolder = new Bitmap(satMap,"auto",false);
			satMapHolder.height = 41;
			satMapHolder.y = 59;
			sliderHolder.addChild(satMapHolder);
			
			lightnessMapHolder = new Bitmap(lightnessMap,"auto",false);
			lightnessMapHolder.height = 41;
			lightnessMapHolder.y = 59 + 59;
			sliderHolder.addChild(lightnessMapHolder);
			
			hueHandle.gotoAndStop(1);
			lightnessHandle.gotoAndStop(1);
			saturationHandle.gotoAndStop(1);
			
			hueHandle.mouseEnabled = false;
			saturationHandle.mouseEnabled = false;
			lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			saturationOverlay.mouseEnabled = false;
			lightnessOverlay.mouseEnabled = false;
			
			
			
			pipette = new Pipette();
			pipette.addEventListener( Event.CHANGE, onPipetteColorPicked );
			addChild(pipette);
			
			pipette.gotoAndStop(1);
			pipette.visible = false;
		}
		
		override protected function onEnabled():void
		{
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			
			setBgType( NavigationBg.BG_TYPE_WOOD );
		}
		
		protected function onSliderMouseDown( event:MouseEvent ):void
		{
			if ( sliderHolder.mouseX < 0 || sliderHolder.mouseX > 256 || sliderHolder.mouseY < 0) return;
			
			activeSliderIndex = sliderHolder.mouseY / 59;
			if ( activeSliderIndex > 2 || sliderHolder.mouseY % 59 > 41 ) return;
			
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			
			
			onSliderMouseMove(event);
		}
		
		protected function onSliderMouseMove( event:MouseEvent ):void
		{
			
			var sx:Number = sliderHolder.mouseX;
			if ( sliderHolder.mouseX < sliderPaddingLeft ) sx = sliderPaddingLeft;
			if ( sliderHolder.mouseX > 255 - sliderPaddingRight) sx = 255 - sliderPaddingRight;
			
			switch ( activeSliderIndex )
			{
				case 0: //hue
					hueHandle.x = sliderHolder.x  + sliderPaddingLeft + sx + sliderOffset;
					currentHSV.hue = 359 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					setCurrentColor( ColorConverter.HSVtoUINT(currentHSV), false, true );
					break;
				case 1: //sat
					saturationHandle.x = sliderHolder.x+ sliderPaddingLeft +  sx + sliderOffset;
					var v:Array = saturationSliderValues[int(255 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight))];
					currentHSV.saturation = v[0];
					currentHSV.value = v[1];
					setCurrentColor(  ColorConverter.HSVtoUINT(currentHSV), false, true );
					break;
				case 2: //lightness
					lightnessHandle.x = sliderHolder.x+ sliderPaddingLeft + sx + sliderOffset;
					currentHSV.value = 100 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					setCurrentColor(  ColorConverter.HSVtoUINT(currentHSV), false, true );
					break;
			}
		}
		
		protected function onSliderMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			
		}
		
		protected function onPaletteColorChanged(event:Event):void
		{
			setCurrentColor( colorPalette.selectedColor, true );
		}
		
		protected function onMixerColorPicked( event:Event ):void {
			setCurrentColor( colorMixer.currentColor, false );
		}
		
		protected function onPipetteColorPicked( event:Event ):void {
			colorMixer.mixEnabled = true;
			setCurrentColor( pipette.currentColor, false );
			pipette.removeEventListener( "PipetteDischarge", onPipetteDischargeOnMixer );
			pipette.removeEventListener( "PipetteDischarge", onPipetteDischargeOnSwatch );
		}
		
		public function setCurrentColor( newColor:uint, fromPalette:Boolean, fromSlider:Boolean = false, triggerChange:Boolean = true ):void
		{
			//trace( "setCurrentColor", newColor, fromPalette, fromSlider, triggerChange);
			currentColor =  newColor;
			currentHSV = ColorConverter.UINTtoHSV(newColor);
			
			var t:ColorTransform = currentColorSwatch.transform.colorTransform;
			t.color = currentColor;
			currentColorSwatch.transform.colorTransform = t;
			
			if ( fromSlider )  colorPalette.changeSelectedColor(t);
			if( triggerChange ) colorChangedSignal.dispatch();
			colorMixer.currentColor = currentColor;
			updateSaturationSlider();
			
			if ( !fromSlider )
			{
				hueHandle.x = sliderOffset + sliderHolder.x + sliderPaddingLeft + (isNaN( currentHSV.hue ) ? 0 : currentHSV.hue) / 360 * (255 -sliderPaddingLeft-sliderPaddingRight);
				saturationHandle.x = sliderOffset + sliderHolder.x +  sliderPaddingLeft + currentHSV.saturation / 100 * (255 -sliderPaddingLeft-sliderPaddingRight)
				lightnessHandle.x = sliderOffset + sliderHolder.x +  sliderPaddingLeft + currentHSV.value / 100 * (255 -sliderPaddingLeft-sliderPaddingRight);
			}
		}
		
		protected function updateSaturationSlider():void
		{
			satMap.lock();
			saturationSliderValues = [];
			var hsv:HSV = currentHSV.clone();
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
		
		public function attemptPipetteCharge( fromLongTap:Boolean ):void
		{
			if ( pipette.visible ) return;
			
			if ( !this.contains(pipette )) this.addChild(pipette);
			//if ( mouseY < -100 || mouseX < -225 || mouseX > 240 ) return;
			if ( colorPalette.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				var swatch:Sprite = colorPalette.getSwatchUnderMouse();
				if ( swatch != null )
				{
					pipette.x = colorPalette.x + swatch.x;
					pipette.y = colorPalette.y + swatch.y - 32;
					pipette.startCharge( swatch.transform.colorTransform.color );
					if ( swatch == colorPalette.getSelectedSwatch() )
					{
						var rgb:uint = colorPalette.getSelectedSwatch().transform.colorTransform.color; 
						currentSwatchMixRed = (rgb >> 16) & 0xff;
						currentSwatchMixGreen= (rgb >> 8) & 0xff;
						currentSwatchMixBlue = rgb & 0xff;
						pipette.addEventListener( "PipetteDischarge", onPipetteDischargeOnSwatch );
					}
					return;
				}
			}
			
			if ( currentColorSwatch.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				pipette.x = currentColorSwatch.x + 10;
				pipette.y = currentColorSwatch.y - 64;
				pipette.startCharge( currentColorSwatch.transform.colorTransform.color );	
			
			} else if ( fromLongTap && colorMixer.hitTestPoint(stage.mouseX,stage.mouseY,true ) )
			{
				colorMixer.mixEnabled = false;
				pipetteDropSize = 1;
				pipette.x = stage.mouseX + 5;
				pipette.y = stage.mouseY - 2;
				pipette.addEventListener( "PipetteDischarge", onPipetteDischargeOnMixer );
				pipette.startCharge( colorMixer.getColorAtMouse() );	
				
			}
			
			
		}
		
		private function onPipetteDischargeOnSwatch( event:Event ):void
		{
			
			
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
			
			colorPalette.selectedColor = currentSwatchMixRed << 16 | currentSwatchMixGreen << 8 | currentSwatchMixBlue;
		}
		
		private function onPipetteDischargeOnMixer( event:Event ):void
		{
			colorMixer.addColorSpot( pipette.x-colorMixer.x,pipette.y-colorMixer.y,pipette.currentColor, pipetteDropSize++);
		}
		
		public function showPipette( holder:Sprite, color:uint, screenPos:Point):void
		{
			if ( !holder.contains(pipette )) holder.addChild(pipette);
			pipette.x = screenPos.x;
			pipette.y = screenPos.y;
			pipette.startCharge( color );	
			
			
		}
	}
}