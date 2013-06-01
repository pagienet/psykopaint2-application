package net.psykosoft.psykopaint2.core.views.components.slider
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class SbSlider extends Sprite
	{
		// Declared in Fla.
		public var handleView:Sprite;
		public var valueLabel:TextField;

		private var _value:Number = 0;
		private var _valueRatio:Number = 0;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _numDecimals:uint = 2;
		private var _minX:Number = 0;
		private var _maxX:Number = 220;
		private var _xRange:Number;
		private var _mouseIsDown:Boolean;
		private var _clickOffset:Number;
		private var _valueRange:Number = 1;

		public function SbSlider() {
			super();
			_xRange = _maxX - _minX;
			valueLabel.selectable = valueLabel.mouseEnabled = false;
			handleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Internal.
		// ---------------------------------------------------------------------

		private function updateHandlePositionFromMouse():void {
			handleView.x = mouseX + _clickOffset;
			if( handleView.x < _minX ) handleView.x = _minX;
			if( handleView.x > _maxX ) handleView.x = _maxX;
			updateValueFromView();
		}

		private function updateViewFromValue():void {
			handleView.x = _minX + _valueRatio * _xRange;
			updateLabel();
		}

		private function updateValueFromView():void {
			_valueRatio = ( handleView.x - _minX ) / _xRange;
			_value = ratioToValue( _valueRatio );
			updateLabel();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		private function updateLabel():void {
			var pow:Number = Math.pow( 10, _numDecimals );
			var num:Number = Math.round( pow * _value ) / pow;
			valueLabel.text = String( num );
		}

		private function valueToRatio( value:Number ):Number {
			return ( value - _minValue ) / _valueRange;
		}

		private function ratioToValue( ratio:Number ):Number {
			return ratio * _valueRange + _minValue;
		}

		private function containValue():void {
			if( _value < _minValue ) _value = _minValue;
			if( _value > _maxValue ) _value = _maxValue;
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
			_valueRatio = valueToRatio( _value );
		}

		public function set maxValue( maxValue:Number ):void {
			_maxValue = maxValue;
			_valueRange = _maxValue - _minValue;
			containValue();
			updateLabel();
			_valueRatio = valueToRatio( _value );
		}

		public function set value( value:Number ):void {
			_value = value;
			containValue();
			_valueRatio = valueToRatio( _value );
			updateLabel();
			updateViewFromValue();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		public function get value():Number {
			return _value;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onHandleMouseDown( event:MouseEvent ):void {
			_mouseIsDown = true;
			_clickOffset = handleView.x - mouseX;
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
