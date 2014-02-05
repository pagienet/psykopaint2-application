package net.psykosoft.psykopaint2.paint.views.color
{
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	
	public class HSLSliders extends Sprite
	{
		public var hueHandle:MovieClip;
		public var saturationHandle:MovieClip;
		public var lightnessHandle:MovieClip;
		
		public var hueOverlay:Sprite;
		public var saturationOverlay:Sprite;
		public var lightnessOverlay:Sprite;
		
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
		private var saturationSliderValues:Array;
		
		private var _userPaintSettings:UserPaintSettingsModel;
		
		
		public function HSLSliders()
		{
			super();
		}
		
		public function setup():void
		{
			hueMap = new TrackedBitmapData(256,1,false,0);
			satMap = new TrackedBitmapData(256,1,false,0);
			lightnessMap = new TrackedBitmapData(256,1,false,0);
			generateHueAndLightnessSliders();
			
			hslSliderHolder = new Sprite();
			hslSliderHolder.x = 2;
			//hslSliderHolder.y = 599;
			addChildAt(hslSliderHolder,Math.min(getChildIndex(hueOverlay),getChildIndex(saturationOverlay),getChildIndex(lightnessOverlay)));
			
			
			hueMapHolder = new Bitmap(hueMap,"auto",false);
			hueMapHolder.height = 41;
			hueMapHolder.y = hueOverlay.y - hslSliderHolder.y - 26;
			hslSliderHolder.addChild(hueMapHolder);
			
			satMapHolder = new Bitmap(satMap,"auto",false);
			satMapHolder.height = 41;
			satMapHolder.y = saturationOverlay.y - hslSliderHolder.y  - 26;
			hslSliderHolder.addChild(satMapHolder);
			
			lightnessMapHolder = new Bitmap(lightnessMap,"auto",false);
			lightnessMapHolder.height = 41;
			lightnessMapHolder.y = lightnessOverlay.y - hslSliderHolder.y  - 26;
			hslSliderHolder.addChild(lightnessMapHolder);
			
			hueHandle.gotoAndStop(1);
			lightnessHandle.gotoAndStop(1);
			saturationHandle.gotoAndStop(1);
			
			hueHandle.mouseEnabled = false;
			saturationHandle.mouseEnabled = false;
			lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			saturationOverlay.mouseEnabled = false;
			lightnessOverlay.mouseEnabled = false;
		}
		
		public function onEnabled():void
		{
			hslSliderHolder.addEventListener(MouseEvent.MOUSE_DOWN, onHSLSliderMouseDown );
			
		}
		
		public function onDisabled():void
		{
			hslSliderHolder.removeEventListener(MouseEvent.MOUSE_DOWN, onHSLSliderMouseDown );
			if ( stage )
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHSLSliderMouseMove );
				stage.removeEventListener(MouseEvent.MOUSE_UP, onHSLSliderMouseUp );
			}
		}
		
		public function set userPaintSettings(value:UserPaintSettingsModel):void
		{
			_userPaintSettings = value;
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
					hueHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;
					_userPaintSettings.hue = sx * 359;
					updateSaturationSlider();
					break;
				case 1: //sat
					saturationHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;
					var v:Array = saturationSliderValues[int(255 * sx)]; 
					_userPaintSettings.saturation = v[0];
					_userPaintSettings.lightness = v[1];
					break;
				case 2: //lightness
					lightnessHandle.x = hslSliderHolder.x  + HSLSliderPaddingLeft + sx * HSLSliderRange;
					_userPaintSettings.lightness = 100 * sx;
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
		
		public function updateSliders():void
		{
			updateSaturationSlider();
			hueHandle.x = HSLSliderOffset + hslSliderHolder.x + HSLSliderPaddingLeft + (isNaN( _userPaintSettings.hue ) ? 0 : _userPaintSettings.hue) / 360 * HSLSliderRange;
			saturationHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.saturation / 100 * HSLSliderRange;
			lightnessHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.lightness / 100 * HSLSliderRange;
		}
	}
}