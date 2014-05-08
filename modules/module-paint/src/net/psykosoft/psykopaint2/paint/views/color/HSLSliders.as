package net.psykosoft.psykopaint2.paint.views.color
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
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
		
		//public var saturationHandle:MovieClip;
		//public var lightnessHandle:MovieClip;
		
		public var hueOverlay:Sprite;
		//public var saturationOverlay:Sprite;
		//public var lightnessOverlay:Sprite;
		
		private var hueMap:BitmapData;
		//private var satMap:BitmapData;
		//private var lightnessMap:BitmapData;
		private var satLightnessMap:BitmapData;
		
		
		private var hueMapHolder:Bitmap;
		//private var satMapHolder:Bitmap;
		//private var lightnessMapHolder:Bitmap;
		private var satLightnessMapHolder:Bitmap;
		
		
		//private var hslSliderHolder:Sprite;
		
		private var activeHSLSliderIndex:int;
		//private var HSLSliderPaddingLeft:Number = 20;
		private var HSLSliderRange:Number = 256;
		//private var HSLSliderOffset:int = 0;
		private var saturationSliderValues:Array;
		
		private var _userPaintSettings:UserPaintSettingsModel;
		public var colorMarker:Sprite;
		public var padOverlay:Sprite;
		public var padContainer:Sprite;
		public var hueContainer:Sprite;
		
		[Embed(source="../../../../../../../../../modules/module-paint/assets/embedded/images/hsb_mask.png")]
		public static var HSBMask:Class;
		
		private var hsb_mask:BitmapData;
		
		public function HSLSliders()
		{
			super();
		}
		
		public function setup():void
		{
			hueMap = new TrackedBitmapData(256,1,false,0);
		//	satMap = new TrackedBitmapData(256,1,false,0);
		//	lightnessMap = new TrackedBitmapData(256,1,false,0);
			satLightnessMap = new TrackedBitmapData(256,100,false,0);
			hsb_mask = (new HSBMask() as Bitmap).bitmapData;
			
			generateHueAndLightnessSliders();
			
			
			hueMapHolder = new Bitmap(hueMap,"auto",false);
			hueMapHolder.height = 41;
			hueContainer.addChild(hueMapHolder);
			
			/*
			satMapHolder = new Bitmap(satMap,"auto",false);
			satMapHolder.height = 41;
			satMapHolder.y = saturationOverlay.y - hslSliderHolder.y  - 26;
			hslSliderHolder.addChild(satMapHolder);
			*/
			
			
			satLightnessMapHolder = new Bitmap(satLightnessMap,"auto",false);
			//satLightnessMapHolder.y = 5.5;
			padContainer.addChild(satLightnessMapHolder);
			/*
			lightnessMapHolder = new Bitmap(lightnessMap,"auto",false);
			lightnessMapHolder.height = 41;
			lightnessMapHolder.y = lightnessOverlay.y - hslSliderHolder.y  - 26;
			hslSliderHolder.addChild(lightnessMapHolder);
			*/
			
			hueHandle.gotoAndStop(1);
		//	lightnessHandle.gotoAndStop(1);
		//	saturationHandle.gotoAndStop(1);
			
			hueHandle.mouseEnabled = false;
			colorMarker.mouseEnabled = false;
		//	saturationHandle.mouseEnabled = false;
		//	lightnessHandle.mouseEnabled = false;
			hueOverlay.mouseEnabled = false;
			padOverlay.mouseEnabled=false;
			//saturationOverlay.mouseEnabled = false;
			//lightnessOverlay.mouseEnabled = false;
			
			//saturationHandle.visible = 
			//lightnessHandle.visible = 
			//saturationOverlay.visible = 
			//lightnessOverlay.visible = false;
			
			
			colorMarker.scaleX = colorMarker.scaleY = 0.5;
		}
		
		public function onEnabled():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onHSLSliderMouseDown );
			
		}
		
		public function onDisabled():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onHSLSliderMouseDown );
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
			//lightnessMap.lock();
			
			
			var h:HSV = new HSV(0,100,100);
			var vd:Number = 1 / 256; 
			var v:Number = 0;
			for ( var i:int = 0; i < 256; i++ )
			{
				h.hue = 360 * v;
				hueMap.setPixel(i,0,ColorConverter.HSVtoUINT(h));
			//	lightnessMap.setPixel(i,0,i << 16 | i << 8 | i);
				v+=vd;
			}
			
			
			hueMap.unlock();
			//lightnessMap.unlock();
			
		}
		
		/*
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
		*/
		
		protected function onHSLSliderMouseDown( event:MouseEvent ):void
		{
			if ( this.mouseX < 0 || this.mouseX > 256 || this.mouseY < 0) return;
			activeHSLSliderIndex = this.mouseY / 59;
			if ( activeHSLSliderIndex > 2 || (activeHSLSliderIndex== 2 && this.mouseY % 59 > 41 )) return;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onHSLSliderMouseMove );
			stage.addEventListener(MouseEvent.MOUSE_UP, onHSLSliderMouseUp );
			onHSLSliderMouseMove(event);
		}
		
		protected function onHSLSliderMouseMove( event:MouseEvent ):void
		{
			var sx:Number = hueMapHolder.mouseX / HSLSliderRange;
			if ( sx < 0 ) sx = 0;
			if ( sx > 1 ) sx = 1;
			
			switch ( activeHSLSliderIndex )
			{
				case 2: //hue
					hueHandle.x =  hueOverlay.x  + sx * HSLSliderRange ;
					_userPaintSettings.hue = sx * 359;
					
					satLightnessMap.lock();
					satLightnessMap.fillRect( satLightnessMap.rect,ColorConverter.HSVtoUINT(new HSV(isNaN(_userPaintSettings.hue) ? 0 : _userPaintSettings.hue,100,100) ));
					satLightnessMap.draw( hsb_mask );
					satLightnessMap.unlock();
					//updateSaturationSlider();
					break;
				case 0:
					
				case 1: //CASE SATU/LUMINOSITY
					
					var mx:Number = Math.min(Math.max(0,satLightnessMapHolder.mouseX),satLightnessMap.width-1);
					var my:Number = Math.min(Math.max(0,satLightnessMapHolder.mouseY),satLightnessMap.height-1);
					
					colorMarker.x = mx;
					colorMarker.y = my;
					TweenLite.to(colorMarker,0.2,{ease:Expo.easeOut,scaleX:1,scaleY:1});
					
					var c:uint = satLightnessMap.getPixel(mx,my);
					var hsv:HSV = ColorConverter.UINTtoHSV( c );
					//hsv.hue = _userPaintSettings.hue;
					if ( isNaN(_userPaintSettings.hue) ) _userPaintSettings.hue = 0;
					_userPaintSettings.lightness = hsv.value;
					_userPaintSettings.saturation = hsv.saturation;
					_userPaintSettings.updateCurrentColorFromHSV();
					//_userPaintSettings.setCurrentColor( colorMatrix.applyMatrix(c));
					break;
				
				/*
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
				*/
			}
			_userPaintSettings.updateCurrentColorFromHSV();
		}
		
		protected function onHSLSliderMouseUp( event:MouseEvent ):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHSLSliderMouseMove );
			stage.removeEventListener(MouseEvent.MOUSE_UP, onHSLSliderMouseUp );
			TweenLite.to(colorMarker,0.25,{ease:Back.easeOut,scaleX:0.5,scaleY:0.5})

		}
		
		public function updateSliders():void
		{
			//updateSaturationSlider();
			//saturationHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.saturation / 100 * HSLSliderRange;
			//lightnessHandle.x = HSLSliderOffset + hslSliderHolder.x +  HSLSliderPaddingLeft + _userPaintSettings.lightness / 100 * HSLSliderRange;
			satLightnessMap.lock();
			satLightnessMap.fillRect( satLightnessMap.rect,ColorConverter.HSVtoUINT(new HSV(isNaN(_userPaintSettings.hue) ? 0 : _userPaintSettings.hue,100,100) ));
			satLightnessMap.draw( hsb_mask );
			satLightnessMap.unlock();
			//colorMarker.x =  (_userPaintSettings.saturation / 100 * 256) ;
			//colorMarker.y = (100-_userPaintSettings.lightness);
			TweenLite.to(colorMarker,0.2,{ease:Expo.easeOut,x:(_userPaintSettings.saturation / 100 * 256),y:(100-_userPaintSettings.lightness)});

			//hueHandle.x =  hueOverlay.x  + (isNaN( _userPaintSettings.hue ) ? 0 : _userPaintSettings.hue) / 360 * HSLSliderRange ;
			TweenLite.to(hueHandle,0.2,{ease:Expo.easeOut,x: (isNaN( _userPaintSettings.hue ) ? 0 : _userPaintSettings.hue) / 360 * HSLSliderRange});

		}
	}
}