package net.psykosoft.psykopaint2.paint.views.color
{
	import com.quasimondo.color.colorspace.HSL;
	import com.quasimondo.color.utils.ColorConverter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
		public var hueHandle:Sprite;
		public var saturationHandle:Sprite;
		public var lightnessHandle:Sprite;
		public var sliderBackdrop:Sprite;
		
		public var hueOverlay:Sprite;
		public var saturationOverlay:Sprite;
		public var lightnessOverlay:Sprite;
		
		public var colorPalette:ColorPalette;
		public var colorChangedSignal:Signal;
		public var currentColor:uint = 0;
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
			colorMixer.y = 595;
			colorMixer.x = 3;
			colorMixer.addEventListener( Event.CHANGE, onMixerColorPicked );
			colorMixer.blendMode = "multiply";
			addChildAt(colorMixer,getChildIndex(colorPalette));
			
			hueMap = new BitmapData(256,1,false,0);
			satMap = new BitmapData(256,1,false,0);
			lightnessMap = new BitmapData(256,1,false,0);
			
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
			
			sliderHolder.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			
			
			switch ( activeSliderIndex )
			{
				case 0: //hue
					hueHandle.x = mouseX;
					setCurrentColor( hueMap.getPixel(sliderHolder.mouseX,0), false );
				break;
				case 1: //sat
					saturationHandle.x = mouseX;
					setCurrentColor( satMap.getPixel(sliderHolder.mouseX,0), false );
				break;
				case 2: //lightness
					lightnessHandle.x = mouseX;
					setCurrentColor( lightnessMap.getPixel(sliderHolder.mouseX,0), false );
				break;
			}
		}
		
		protected function onSliderMouseMove( event:MouseEvent ):void
		{
			var sx:Number = sliderHolder.mouseX;
			if ( sliderHolder.mouseX < 0 ) sx = 0;
			if ( sliderHolder.mouseX > 256 ) sx = 256;
			
			switch ( activeSliderIndex )
			{
				case 0: //hue
					hueHandle.x = sliderHolder.x + sx;
					setCurrentColor( hueMap.getPixel(sx,0), false );
					break;
				case 1: //sat
					saturationHandle.x = sliderHolder.x+ sx;
					setCurrentColor( satMap.getPixel(sx,0), false );
					break;
				case 2: //lightness
					lightnessHandle.x = sliderHolder.x+sx;
					setCurrentColor( lightnessMap.getPixel(sx,0), false );
					break;
			}
		}
		
		protected function onSliderMouseUp( event:MouseEvent ):void
		{
			sliderHolder.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp );
			
		}
		
		protected function onPaletteColorChanged(event:Event):void
		{
			setCurrentColor( colorPalette.selectedColor, true );
		}
		
		protected function onMixerColorPicked( event:Event ):void {
			setCurrentColor( colorMixer.currentColor, false );
		}
		
		protected function setCurrentColor( newColor:uint, fromPalette:Boolean):void
		{
			currentColor = newColor;
			var t:ColorTransform = currentColorSwatch.transform.colorTransform;
			t.color = newColor;
			currentColorSwatch.transform.colorTransform = t;
			if (!fromPalette )  colorPalette.selectedIndex = -1;
			colorChangedSignal.dispatch();
			colorMixer.currentColor = newColor;
			updateColorSliders();
		}
		
		protected function updateColorSliders():void
		{
			hueMap.lock();
			satMap.lock();
			lightnessMap.lock();
			var hsl:HSL = ColorConverter.UINTtoHSL(currentColor);
			
			var h:HSL = hsl.clone();
			var s:HSL = hsl.clone();
			var l:HSL = hsl.clone();
			var vd:Number = 1 / 256; 
			var v:Number = 0;
			for ( var i:int = 0; i < 256; i++ )
			{
				h.hue = 360 * v;
				s.saturation = 100 * v;
				l.lightness = 100 * v;
				hueMap.setPixel(i,0,ColorConverter.HSLtoUINT(h));
				satMap.setPixel(i,0,ColorConverter.HSLtoUINT(s));
				lightnessMap.setPixel(i,0,ColorConverter.HSLtoUINT(l));
								
				v+=vd;
			}
			
			hueMap.unlock();
			satMap.unlock();
			lightnessMap.unlock()
		}
	}
}