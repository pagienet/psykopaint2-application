package net.psykosoft.psykopaint2.core.views.components.slider
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class SliderBase extends Sprite
	{
		public static var LABEL_VALUE:int = 0;
		public static var LABEL_PERCENT:int = 1;
		public static var LABEL_DEGREES:int = 2;
			
		private var _handleView:Sprite;
		private var _bgView:Sprite;
		private var _valueLabel:TextField;
		private var _value:Number = 0;
		private var _valueRatio:Number = 0;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _minX:Number = 0;
		private var _maxX:Number = 220;
		private var _xRange:Number;
		private var _mouseIsDown:Boolean;
		private var _clickOffset:Number;
		private var _valueRange:Number = 1;
		private var _labelMode:int = 1;
		private var _digits:int = 2;
		
		public function SliderBase() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function setRange( min:Number, max:Number ):void {
			_minX = min;
			_maxX = max;
			_xRange = _maxX - _minX;
		}

		public function setHandle( value:Sprite ):void {
			_handleView = value;
			_handleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
		}

		public function setBg( value:Sprite ):void {
			_bgView = value;
	   		_bgView.addEventListener( MouseEvent.MOUSE_DOWN, onBgMouseDown );
		}

		public function setLabel( value:TextField ):void {
			_valueLabel = value;
			_valueLabel.selectable = _valueLabel.mouseEnabled = false;
		}

		// ---------------------------------------------------------------------
		// Internal.
		// ---------------------------------------------------------------------

		private function updateHandlePositionFromMouse():void {
			_handleView.x = mouseX + _clickOffset;
			if( _handleView.x < _minX ) _handleView.x = _minX;
			if( _handleView.x > _maxX ) _handleView.x = _maxX;
			updateValueFromView();
		}

		private function updateViewFromValue():void {
			_handleView.x = _minX + _valueRatio * _xRange;
			updateLabel();
		}

		private function updateValueFromView():void {
			_valueRatio = ( _handleView.x - _minX ) / _xRange;
			_value = ratioToValue( _valueRatio );
			updateLabel();
			dispatchEvent( new Event( Event.CHANGE ) );
		}

		private function updateLabel():void {
			switch ( _labelMode )
			{
				case LABEL_VALUE:
					_valueLabel.text = formatLabel(_value);
					break;
				case LABEL_PERCENT:
					_valueLabel.text = formatLabel(_valueRatio * 100,"%" );
					break;
				case LABEL_DEGREES:
					_valueLabel.text = formatLabel(_value, "°" );
					break;
			}
		}

		private function valueToRatio( value:Number ):Number {
			return ( value - _minValue ) / _valueRange;
		}

		private function ratioToValue( ratio:Number ):Number {
			return ratio * _valueRange + _minValue;
		}
		
		private function formatLabel( value:Number, suffix:String = "" ):String
		{
			return String( int(value * Math.pow( 10, _digits) + 0.5) / Math.pow( 10, _digits)) + suffix;
		}

		private function containValue():void {
			if( _value < _minValue ) _value = _minValue;
			if( _value > _maxValue ) _value = _maxValue;
		}

		public function setWidth( newWidth:Number ):void{
			_bgView.width = newWidth;
			_maxX = newWidth - _handleView.width;
			_xRange = _maxX - _minX;
			updateViewFromValue();
			_valueLabel.x = newWidth + 20;
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
		
		public function get labelMode( ):int {
			return _labelMode;
		}
		
		public function set labelMode( value:int ):void {
			_labelMode = value;
		}
		
		public function get digits( ):int {
			return _digits;
		}
		
		public function set digits( value:int ):void {
			_digits = value;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onHandleMouseDown( event:MouseEvent ):void {
			_mouseIsDown = true;
			_clickOffset = _handleView.x - mouseX;
		}

		private function onBgMouseDown( event:MouseEvent ):void {
			_clickOffset = -_handleView.width/2;
			updateHandlePositionFromMouse();
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
