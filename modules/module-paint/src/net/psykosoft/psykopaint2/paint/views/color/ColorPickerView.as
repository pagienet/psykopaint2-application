package net.psykosoft.psykopaint2.paint.views.color
{
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.Colormixer;
	import net.psykosoft.psykopaint2.core.views.components.colormixer.FluidColorMixer;
	
	import org.osflash.signals.Signal;
	
	public class ColorPickerView extends ViewBase
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
		//private var colorMixer:Colormixer;
		private var colorMixer:FluidColorMixer;
		
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

		private var hueHandleBg:Shape;

		private var saturationHandleBg:Shape;

		private var lightnessHandleBg:Shape;
		
		public function ColorPickerView()
		{
			super();
			colorChangedSignal = new Signal();
		}
		
		override protected function onSetup():void 
		{
			colorPalette.addEventListener( Event.CHANGE, onPaletteColorChanged );
			//colorMixer = new Colormixer( colorPalette.currentPalette );
			colorMixer = new FluidColorMixer();
			//colorMixer = new Colormixer(colorPalette.currentPalette);
			colorMixer.y = 595;
			colorMixer.x = 3;
			colorMixer.addEventListener( Event.CHANGE, onMixerColorPicked );
			colorMixer.blendMode = "multiply";
			addChildAt(colorMixer,getChildIndex(colorPalette));
			
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
			
			
			//hueHandle.blendMode = saturationHandle.blendMode = lightnessHandle.blendMode = "multiply";
			hueHandle.gotoAndStop(3);
			hueHandleBg = new Shape();
			hueHandleBg.graphics.beginFill(0);
			hueHandleBg.graphics.moveTo(-18,-25);
			hueHandleBg.graphics.lineTo(20,-23);
			hueHandleBg.graphics.lineTo(18,16);
			hueHandleBg.graphics.lineTo(-20,13);
			hueHandleBg.graphics.endFill();
			hueHandle.addChildAt(hueHandleBg,0);
			
			saturationHandle.gotoAndStop(3);
			saturationHandleBg = new Shape();
			saturationHandleBg.graphics.beginFill(0);
			saturationHandleBg.graphics.moveTo(-18,-25);
			saturationHandleBg.graphics.lineTo(20,-23);
			saturationHandleBg.graphics.lineTo(18,16);
			saturationHandleBg.graphics.lineTo(-20,13);
			saturationHandleBg.graphics.endFill();
			saturationHandle.addChildAt(saturationHandleBg,0);
			
			lightnessHandle.gotoAndStop(3);
			lightnessHandleBg = new Shape();
			
			lightnessHandleBg.graphics.beginFill(0);
			lightnessHandleBg.graphics.moveTo(-18,-25);
			lightnessHandleBg.graphics.lineTo(20,-23);
			lightnessHandleBg.graphics.lineTo(18,16);
			lightnessHandleBg.graphics.lineTo(-20,13);
			lightnessHandleBg.graphics.endFill();
			lightnessHandle.addChildAt(lightnessHandleBg,0);
			
			
			hueHandle.mouseEnabled = false;
			saturationHandle.mouseEnabled = false;
			lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			saturationOverlay.mouseEnabled = false;
			lightnessOverlay.mouseEnabled = false;
			
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
					hueHandle.x = sliderHolder.x  + sliderPaddingLeft + sx;
					currentHSV.hue = 359 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					setCurrentColor( false );
					break;
				case 1: //sat
					saturationHandle.x = sliderHolder.x+ sliderPaddingLeft +  sx;
					var v:Array = saturationSliderValues[int(255 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight))];
					currentHSV.saturation = v[0];
					currentHSV.value = v[1];
					setCurrentColor( false );
					break;
				case 2: //lightness
					lightnessHandle.x = sliderHolder.x+ sliderPaddingLeft + sx;
					currentHSV.value = 100 * (sx - sliderPaddingLeft) / (255 -sliderPaddingLeft - sliderPaddingRight);
					
					setCurrentColor( false );
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
			currentHSV = ColorConverter.UINTtoHSV(colorPalette.selectedColor);
			setCurrentColor( true );
		}
		
		protected function onMixerColorPicked( event:Event ):void {
			currentHSV = ColorConverter.UINTtoHSV( colorMixer.currentColor);
			setCurrentColor( false );
		}
		
		protected function setCurrentColor( fromPalette:Boolean):void
		{
			currentColor =  ColorConverter.HSVtoUINT(currentHSV);
			var t:ColorTransform = currentColorSwatch.transform.colorTransform;
			t.color = currentColor;
			currentColorSwatch.transform.colorTransform = t;
			saturationHandleBg.transform.colorTransform = t;
			/*
			var hsv:HSV = currentHSV.clone();
			hsv.value = 100;
			hsv.saturation = 100;
			t.color = ColorConverter.HSVtoUINT(hsv);
			*/
			hueHandleBg.transform.colorTransform = t;
			/*
			var p:int = currentHSV.value * 255 / 100;
			t.color = p << 16 | p << 8 | p;
			*/
			lightnessHandleBg.transform.colorTransform = t;
			
			
			if (!fromPalette )  colorPalette.selectedIndex = -1;
			colorChangedSignal.dispatch();
			colorMixer.currentColor = currentColor;
			updateSaturationSlider();
			
			
			hueHandle.x = sliderHolder.x + sliderPaddingLeft + currentHSV.hue / 360 * (255 -sliderPaddingLeft-sliderPaddingRight);
			saturationHandle.x = sliderHolder.x +  sliderPaddingLeft + currentHSV.saturation / 100 * (255 -sliderPaddingLeft-sliderPaddingRight)
			lightnessHandle.x = sliderHolder.x +  sliderPaddingLeft + currentHSV.value / 100 * (255 -sliderPaddingLeft-sliderPaddingRight);
			
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
	}
}