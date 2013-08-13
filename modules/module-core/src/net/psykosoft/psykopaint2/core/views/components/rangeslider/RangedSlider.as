package net.psykosoft.psykopaint2.core.views.components.rangeslider
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class RangedSlider extends Sprite
	{
		public static var LABEL_VALUE:int = 0;
		public static var LABEL_PERCENT:int = 1;
		public static var LABEL_DEGREES:int = 2
			
		// Declared in Fla.
		public var leftHandleView:Sprite;
		public var rightHandleView:Sprite;
		public var bgView:Sprite;
		public var rangeView:MovieClip;
		public var value1Label:TextField;
		public var value2Label:TextField;

		private var _value1:Number = 0;
		private var _value2:Number = 0;
		private var _valueRatio1:Number = 0;
		private var _valueRatio2:Number = 0;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _minX:Number = 0;
		private var _maxX:Number = 220;
		private var _xRange:Number;
		private var _mouseIsDown:Boolean;
		private var _clickOffset:Number;
		private var _valueRange:Number = 1;
		private var _width:Number = 451;
		private var _activeHandle:Sprite;
		private var _labelMode:int = 1;
		
		public function RangedSlider() {
			super();
			_minX = leftHandleView.x;
			_maxX = rightHandleView.x;
			_xRange = _maxX - _minX;
			rangeView.stop();
			value1Label.selectable = value1Label.mouseEnabled = false;
			value2Label.selectable = value2Label.mouseEnabled = false;
			leftHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
			rightHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
			rangeView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Internal.
		// ---------------------------------------------------------------------

		private function updateHandlePositionFromMouse():void {
			_activeHandle.x = mouseX + _clickOffset;
			// Handle collisions and edge containment.
			if( _activeHandle == leftHandleView ) {
				// Edge.
				if( leftHandleView.x < _minX ) leftHandleView.x = _minX;
				else if( leftHandleView.x > _maxX ) leftHandleView.x = _maxX;
				// Collision.
				if( rightHandleView.x < leftHandleView.x ) rightHandleView.x = leftHandleView.x;
				updateAccordion();
			}
			else if( _activeHandle == rightHandleView ) {
				// Edge.
				if( rightHandleView.x > _maxX ) rightHandleView.x = _maxX;
				else if( rightHandleView.x < _minX ) rightHandleView.x = _minX;
				// Collision.
				if( leftHandleView.x > rightHandleView.x ) leftHandleView.x = rightHandleView.x;
				updateAccordion();
			}
			else {
				var currentDistanceBetweenHandles:Number = rightHandleView.x - leftHandleView.x;
				var limit:Number = _maxX - currentDistanceBetweenHandles;
				var dx:Number;
				if( rangeView.x < _minX ) {
					dx = _minX - rangeView.x;
					rightHandleView.x = _minX + currentDistanceBetweenHandles - dx;
					if( rightHandleView.x < _minX ) rightHandleView.x = _minX;
					rangeView.x = leftHandleView.x = _minX;
					_clickOffset += dx;
					updateAccordion();
				}
				else if( rangeView.x > limit ) {
					dx = _maxX - ( rangeView.x + currentDistanceBetweenHandles );
					leftHandleView.x = _maxX - currentDistanceBetweenHandles - dx;
					if( leftHandleView.x > _maxX ) leftHandleView.x = _maxX;
					rightHandleView.x = _maxX;
					updateAccordion();
				}
				else {
					leftHandleView.x = rangeView.x;
					rightHandleView.x = leftHandleView.x + currentDistanceBetweenHandles;
				}
			}
			updateValueFromView();
		}

		private function updateAccordion():void {
			// Position.
			rangeView.x = leftHandleView.x;
			// "Scale"
			var currentDistanceBetweenHandles:Number = rightHandleView.x - leftHandleView.x;
			var xRatio:Number = currentDistanceBetweenHandles / _xRange;
			var frame:Number = 101 * ( 1 - xRatio );
			rangeView.gotoAndStop( uint( frame ) );
			rangeView.visible = rangeView.currentFrame < 100;
		}

		private function updateValueFromView():void {
			_valueRatio1 = ( leftHandleView.x - _minX ) / _xRange;
			_valueRatio2 = ( rightHandleView.x - _minX ) / _xRange;
			_value1 = ratioToValue( _valueRatio1 );
			_value2 = ratioToValue( _valueRatio2 );
			updateLabel();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		private function updateViewFromValue():void {
			leftHandleView.x = _minX + _valueRatio1 * _xRange;
			rightHandleView.x = _minX + _valueRatio2 * _xRange;
			updateLabel();
			updateAccordion();
		}

		private function updateLabel():void 
		{
			switch ( _labelMode )
			{
				case LABEL_VALUE:
					value1Label.text = String( _value1 );
					value2Label.text = String( _value2 );
					break;
				case LABEL_PERCENT:
					var percentage:Number = Math.round(_valueRatio1*100);
					value1Label.text = String( percentage + "%" );
					
					percentage = Math.round(_valueRatio2*100);
					value2Label.text = String( percentage + "%"  );
					break;
				case LABEL_DEGREES:
					value1Label.text = String( int(_value1+0.5) + "°" );
					value2Label.text = String( int(_value2+0.5) + "°" );
					break;
			}
		}
		
		private function valueToRatio( value:Number ):Number {
			return ( value - _minValue ) / _valueRange;
		}

		private function ratioToValue( ratio:Number ):Number {
			return ratio * _valueRange + _minValue;
		}

		private function containValue():void {
			if( _value1 < _minValue ) _value1 = _minValue;
			if( _value1 > _maxValue ) _value1 = _maxValue;
			if( _value2 < _minValue ) _value2 = _minValue;
			if( _value2 > _maxValue ) _value2 = _maxValue;
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function dispose():void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		public function set minValue( minValue:Number ):void {
			_minValue = minValue;
			_valueRange = _maxValue - _minValue;
			containValue();
			updateLabel();
			_valueRatio1 = valueToRatio( _value1 );
			_valueRatio2 = valueToRatio( _value2 );
		}

		public function set maxValue( maxValue:Number ):void {
			_maxValue = maxValue;
			_valueRange = _maxValue - _minValue;
			containValue();
			updateLabel();
			_valueRatio1 = valueToRatio( _value1 );
			_valueRatio2 = valueToRatio( _value2 );
		}

		public function set value1( value:Number ):void {
			_value1 = value;
			containValue();
			_valueRatio1 = valueToRatio( _value1 );
			updateLabel();
			updateViewFromValue();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		public function set value2( value:Number ):void {
			_value2 = value;
			containValue();
			_valueRatio2 = valueToRatio( _value2 );
			updateLabel();
			updateViewFromValue();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		public function get value1():Number {
			return _value1;
		}

		public function get value2():Number {
			return _value2;
		}

		override public function get width():Number {
			return _width;
		}

		public function setWidth( newWidth:Number ):void{
			_width = newWidth;
			bgView.width = newWidth;
			rangeView.width = newWidth - 180;
			_maxX = newWidth - 95;
			value2Label.x = newWidth - 70;
			_xRange = _maxX - _minX;
			updateViewFromValue();
		}
		
		public function set labelMode( value:int ):void {
			_labelMode = value;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onHandleMouseDown( event:MouseEvent ):void {
			_mouseIsDown = true;
			_activeHandle = event.target as Sprite;
			_clickOffset = _activeHandle.x - mouseX;
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		private function onStageMouseMove( event:MouseEvent ):void {
			if( _mouseIsDown ) {
				updateHandlePositionFromMouse();
			}
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_mouseIsDown = false;
		}
	}
}