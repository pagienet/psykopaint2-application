package net.psykosoft.psykopaint2.app.view.components.sliders
{
	import net.psykosoft.psykopaint2.app.managers.assets.Fonts;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class PaperRangeSlider extends Sprite
	{
		public static const CHANGE : String = "onChange";
		public static const START_DRAG : String = "THUMB_DOWN";
		public static const UPDATE : String = "onUpdate";
		public static const ON_MOVE : String = "onMoveUpdate";
		public static const STOP_DRAG : String = "STOP_DRAG";
		
		
		protected var _minValue : Number = 0;
		protected var _maxValue : Number = 100;
		protected var _minPosX : Number = 0;
		protected var _maxPosX : Number = 200;
		//SHIFT POSITION OF HANDLE
		protected var _leftHandleShiftX : Number = 10;
		protected var _rightShiftX:Number=0;
		
		private var _value1:Number=0;
		private var _value2:Number=0;
		
		private var _labelLeft:TextField;
		private var _labelRight:TextField;
		
		private var _bgView:Image;
		private var _leftHandleView:Image;
		private var _rightHandleView:Image;
		private var _rangeView:MovieClip;
		private var _initialTouchPosition:Number;
		private var _initialValues:Array;
		
		public function PaperRangeSlider()
		{
			super();
			
			
			_bgView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("rangeSliderBg"));
			this.addChild(_bgView); 
			
			 var rangeFrames:Vector.<Texture> = Psykopaint2Ui.instance.uiComponentsAtlas.getTextures("sliderRangeBar");
			_rangeView = new MovieClip(rangeFrames,60);
			this.addChild(_rangeView); 
			_rangeView.y=-6;
			
			
			_labelLeft = new TextField(50,30,"0",Fonts.Warugaki,20,0);
			_labelRight = new TextField(50,30,"0",Fonts.Warugaki,20,0);
			_labelLeft.x = 27;
			_labelRight.x = 398;
			_labelLeft.y = 7;
			_labelRight.y = 7;
			this.addChild(_labelRight);
			this.addChild(_labelLeft);
			
			_leftHandleView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("left head"));
			this.addChild(_leftHandleView); 
			
			_rightHandleView = new Image(Psykopaint2Ui.instance.uiComponentsAtlas.getTexture("right head"));
			this.addChild(_rightHandleView); 
			
			
			
			_minPosX =  81;
			_maxPosX =  369;
			_leftHandleShiftX = - _leftHandleView.width/2;
			_rightShiftX = _leftHandleView.width;
			
			
			//new MoveButtonDecorator(_handleView,0.1,{scaleX:0.95,scaleY:0.95,transition:Transitions.EASE_OUT});
			
			setValue(_value1,0);
			setValue(_value2,1);
			
			_leftHandleView.addEventListener(TouchEvent.TOUCH, onTouchEventLeftHandle);
			_rightHandleView.addEventListener(TouchEvent.TOUCH, onTouchEventRightHandle);
			_rangeView.addEventListener(TouchEvent.TOUCH, onTouchEventHandle);
			
		}
		
		private function onTouchEventHandle(e:TouchEvent):void
		{
			
			var touch:Touch = e.touches[0];
			var posX:Number = touch.getLocation(this).x;
			if (touch.phase == TouchPhase.BEGAN){
				_initialTouchPosition=posX;
				_initialValues = [_value1,_value2];
			}else if (touch.phase == TouchPhase.MOVED){
				
				//GET MOUSE X POSITION
				var shiftX:Number =posX- _initialTouchPosition ;
				
				var shiftValue:Number = shiftX* totalRangeOfValues/rangePosition;
				
				//APPLY THE SHIFTED VALUE
				setValues(_initialValues[0]+shiftValue,_initialValues[1]+shiftValue);
				
				
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
		}		
		
		private function onTouchEventLeftHandle(e:TouchEvent):void
		{
			var touch:Touch = e.touches[0];
			if (touch.phase == TouchPhase.BEGAN){
				
			}else if (touch.phase == TouchPhase.MOVED){
				
				//GET MOUSE X POSITION
				var posX:Number = touch.getLocation(this).x;
				posX =  Math.max(Math.min(posX,_maxPosX),_minPosX);
				
				//CONVERT TOUCH POSITION TO VALUE
				var slideValue:Number = positionToValue(posX);

				//APPLY THE VALUE
				setValue(slideValue,0);
				//trace("drag LEFT handle slideValue= "+slideValue+" | _leftHandleView.x = "+	_leftHandleView.x );

				
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
		}		
		
		private function onTouchEventRightHandle(e:TouchEvent):void
		{
			var touch:Touch = e.touches[0];
			if (touch.phase == TouchPhase.BEGAN){
				
			}else if (touch.phase == TouchPhase.MOVED){
				
				//GET MOUSE X POSITION
				var posX:Number = touch.getLocation(this).x;
				posX = Math.max(Math.min(posX-_rightShiftX,_maxPosX),_minPosX-_rightShiftX);
				
				//CONVERT TOUCH POSITION TO VALUE
				var slideValue:Number = positionToValue(posX);
				
				setValue(slideValue,1);
				//trace("drag RIGHT handle slideValue= "+slideValue+" | 	_rightHandleView.x = "+	_rightHandleView.x );
				
				
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
			
		}
		
		public function setValues(val1:Number,val2:Number):void{
			setValue(val1,0);
			setValue(val2,1);
			
		}
		
		public function setValue(val:Number,index:int=0):void{
			
			//SET VALUE WITHIN BOUNDS
			val = Math.max(Math.min(val,_maxValue),_minValue);
			
			trace("setValue["+index+"] val="+val);
			if(index==0){
				
				_value1 = val;
				_leftHandleView.x =  _leftHandleShiftX+_minPosX+ rangePosition * (_value1 - _minValue) / (totalRangeOfValues) ;
				
				repositionRange();
				
				//IF VALUE 2 CANNOT BE LOWER THAN VALUE 1
				if(_value2<_value1) setValue(_value1,1);
				
				
				_labelLeft.text = String(Math.round(_value1));
				
			}else {
				_value2 = val;
				_rightHandleView.x = _leftHandleShiftX+_rightShiftX+ _minPosX+ rangePosition * (_value2 - _minValue) / totalRangeOfValues ;
				
				repositionRange();
				
				
				//VALUE 1 CANNOT BE HIGHER THAN VALUE 2
				if(_value1>_value2) setValue(_value2,0);
				
				
				_labelRight.text = String(Math.round(_value2));

			}
			dispatchEvent(new Event(PaperSlider.CHANGE));
		}
		
		private function repositionRange():void
		{
			_rangeView.x = _leftHandleView.x+_leftHandleView.width-2;
			_rangeView.currentFrame= Math.min(Math.max(100-int(_value2-_value1),0),99);
			if(_rangeView.currentFrame>=99){
				_rangeView.visible=false;
			}else {_rangeView.visible=true}
		}		
		
		public function getValues():Array{
			
			return [_value1,_value2];
		}
		
		
		private function positionToValue(posX:Number):Number{
			
			return  _minValue + totalRangeOfValues * ((posX - _minPosX) / rangePosition);
		}
		
		private function valueToPosition(val:Number):Number{
			var valueRatio:Number = (val - _minValue) / totalRangeOfValues;
			
			return  _minPosX + rangePosition *valueRatio;
		}
		
		
		private function positionToValueRight(posX:Number):Number{
			
			return  _minValue + totalRangeOfValues * ((posX - _minPosX) / rangePosition);
		}
		
		private function valueToPositionRight(val:Number):Number{
			var valueRatio:Number = (val - _minValue) / totalRangeOfValues;
			
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
			return _value2-_value1;
		}
		
		public function get totalRangeOfValues() : Number
		{
			return _maxValue - _minValue;
		}
		public function get rangePosition() : Number
		{
			return _maxPosX - _minPosX;
		}
	}
}