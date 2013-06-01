package net.psykosoft.psykopaint2.core.views.components
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class SbRangedSlider extends Sprite
	{
		// Declared in Fla.
		public var leftHandleView:Sprite;
		public var rightHandleView:Sprite;
		public var rangeView:MovieClip;
		public var value1Label:TextField;
		public var value2Label:TextField;

		private var _value1:Number = 0;
		private var _value2:Number = 0;
		private var _valueRatio1:Number = 0;
		private var _valueRatio2:Number = 0;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _numDecimals:uint = 2;
		private var _minX:Number = 0;
		private var _maxX:Number = 220;
		private var _xRange:Number;
		private var _mouseIsDown:Boolean;
		private var _clickOffset:Number;
		private var _valueRange:Number = 1;
		private var _activeHandle:Sprite;
		private var _initialDistanceBetweenHandles:Number;

		public function SbRangedSlider() {
			super();
			_minX = leftHandleView.x;
			_maxX = rightHandleView.x;
			_initialDistanceBetweenHandles = rightHandleView.x - leftHandleView.x;
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
				if( leftHandleView.x > _maxX ) leftHandleView.x = _maxX;
				// Collision.
				if( rightHandleView.x < leftHandleView.x ) rightHandleView.x = leftHandleView.x;
				updateAccordion();
			}
			else if( _activeHandle == rightHandleView ) {
				// Edge.
				if( rightHandleView.x > _maxX ) rightHandleView.x = _maxX;
				if( rightHandleView.x < _minX ) rightHandleView.x = _minX;
				// Collision.
				if( leftHandleView.x > rightHandleView.x ) leftHandleView.x = rightHandleView.x;
				updateAccordion();
			}
			else {
				var currentDistanceBetweenHandles:Number = rightHandleView.x - leftHandleView.x;
				if( rangeView.x < _minX ) rangeView.x = _minX;
				var limit:Number = _maxX - currentDistanceBetweenHandles;
				if( rangeView.x > limit ) rangeView.x = limit;
				leftHandleView.x = rangeView.x;
				rightHandleView.x = leftHandleView.x + currentDistanceBetweenHandles;
			}
			updateValueFromView();
		}

		private function updateAccordion():void {
			// Position.
			rangeView.x = leftHandleView.x;
			// "Scale"
			var currentDistanceBetweenHandles:Number = rightHandleView.x - leftHandleView.x;
			var xRatio:Number = currentDistanceBetweenHandles / _initialDistanceBetweenHandles;
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

		private function updateLabel():void {
			var pow:Number = Math.pow( 10, _numDecimals );
			var num:Number = Math.round( pow * _value1 ) / pow;
			value1Label.text = String( num );
			num = Math.round( pow * _value2 ) / pow;
			value2Label.text = String( num );
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

		public function set numDecimals( numDecimals:int ):void {
			_numDecimals = numDecimals;
			updateLabel();
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
			return 451;
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