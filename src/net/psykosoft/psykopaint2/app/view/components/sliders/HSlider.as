package net.psykosoft.psykopaint2.app.view.components.sliders
{
	
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.utils.decorators.InvertButtonDecorator;
	import net.psykosoft.psykopaint2.utils.decorators.MoveButtonDecorator;
	
	import starling.animation.Transitions;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class HSlider extends Sprite
	{
		
		public static const CHANGE : String = "onChange";
		public static const START_DRAG : String = "THUMB_DOWN";
		public static const UPDATE : String = "onUpdate";
		public static const ON_MOVE : String = "onMoveUpdate";
		public static const STOP_DRAG : String = "STOP_DRAG";
		
		private var _bgView:Image;
		private var _handleView:Image;
		protected var _minValue : Number = 0;
		protected var _maxValue : Number = 100;
		protected var _minPosX : Number = 0;
		protected var _maxPosX : Number = 200;
		//SHIFT POSITION OF HANDLE
		protected var _shiftX : Number = 20;
		
		private var _value:Number;
		
		public function HSlider()
		{
			super();
			
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("sliderBg"));
			this.addChild(_bgView); 
			
			_handleView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("sliderHandle"));
			this.addChild(_handleView); 
			
			_shiftX = -_handleView.width/2;
			_minPosX =  35;
			_maxPosX =  _bgView.width-35;
			new MoveButtonDecorator(_handleView,0.1,{scaleX:0.95,scaleY:0.95,transition:Transitions.EASE_OUT});
			
			_handleView.x=_minPosX+_shiftX;
			
			this.addEventListener(TouchEvent.TOUCH, onTouchEvent);
			
		}
		
		private function onTouchEvent(e:TouchEvent):void
		{
			var touch:Touch = e.touches[0];
			if (touch.phase == TouchPhase.BEGAN){
				
			}else if (touch.phase == TouchPhase.MOVED){
				
				var posX:Number = touch.getLocation(this).x;
				_handleView.x = Math.max(Math.min(posX,_maxPosX),_minPosX);
				var slideValue:Number = positionToValue(_handleView.x);
				_handleView.x += _shiftX;

				
				
				setValue(slideValue);
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
		}		
		
		
		public function setValue(val):void{
			val = Math.max(Math.min(val,_maxValue),_minValue);
			_value = val;
			
			//MOVE SLIDER
			var valueRatio:Number = (val - _minValue) / rangeValue;
			_handleView.x = _shiftX+ _minPosX+ rangePosition * valueRatio ;
			
			
			
			dispatchEvent(new Event(HSlider.CHANGE));
			
			trace("value = "+_value);
		}
		
		
		private function positionToValue(posX:Number):Number{
			
			return  _minValue + rangeValue * ((posX - _minPosX) / rangePosition);
		}
		
		private function valueToPosition(val:Number):Number{
			var valueRatio:Number = (val - _minValue) / rangeValue;
			
			return  _minPosX + rangePosition *valueRatio;
		}
		
		
		public function get minValue() : Number
		{
			return _minValue;
		}
		
		public function set minValue(minValue : Number) : void
		{
			_minValue = minValue;
		}
		
		public function get maxValue() : Number
		{
			return _maxValue;
		}
		
		public function set maxValue(maxValue : Number) : void
		{
			_maxValue = maxValue;
		}
		
		public function get rangeValue() : Number
		{
			return _maxValue - _minValue;
		}
		public function get rangePosition() : Number
		{
			return _maxPosX - _minPosX;
		}
		
		
	}
}