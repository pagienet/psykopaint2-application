package net.psykosoft.psykopaint2.core.views.components
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class SbSlider extends Sprite
	{
		// Declared in Fla.
		public var bgView:Sprite;
		public var handleView:Sprite;

		private var _mouseDown:Boolean;
		private var _minimum:Number = 0;
		private var _maximum:Number = 100;
		private var _minPosX:Number = 0;
		private var _maxPosX:Number = 200;
		private var _shiftX:Number = 20;
		private var _value:Number;
		private var _sliderIdLabel:TextField;
		private var _sliderValueLabel:TextField;
		private var _numDecimals:uint = 1;
		private var _stage:Stage;

		public static const CHANGE:String = "onChange";
		public static const STOP_DRAG:String = "STOP_DRAG"; // TODO: borrar si no se usa
		// TODO: de hecho, reemplazar estos por Event.CHANGE

		public function SbSlider() {
			super();

			_sliderIdLabel = new TextField();
			_sliderIdLabel.mouseEnabled = false;
			_sliderIdLabel.selectable = false;
			_sliderIdLabel.width = _sliderIdLabel.height = 1;
			_sliderIdLabel.y = 40;
			addChild( _sliderIdLabel );

			_sliderValueLabel = new TextField();
			_sliderValueLabel.mouseEnabled = false;
			_sliderValueLabel.selectable = false;
			_sliderIdLabel.width = _sliderIdLabel.height = 1;
            _sliderValueLabel.x = 220;
			_sliderValueLabel.y = 40;
			addChild( _sliderValueLabel );

			setValue( Number.MIN_VALUE );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			_shiftX = -handleView.width / 2;
			_minPosX = -_shiftX;
			_maxPosX = bgView.width + _shiftX;

			handleView.x = _minPosX + _shiftX;

			handleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );

			_stage = stage;

			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		public function dispose():void {
			handleView.removeEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			_stage = null;
		}

		private function onHandleMouseDown( e:MouseEvent ):void {
			_mouseDown = true;
		}

		private function onStageMouseUp( e:MouseEvent ):void {
			_mouseDown = false;
		}

		private function onStageMouseMove( event:MouseEvent ):void {
			if( _mouseDown ) {
				handleView.x = Math.max( Math.min( mouseX, _maxPosX ), _minPosX );
				var slideValue:Number = positionToValue( handleView.x );
				handleView.x += _shiftX;
				setValue( slideValue );
			}
		}

		private function positionToValue( posX:Number ):Number {
			return  _minimum + rangeValue * ( ( posX - _minPosX ) / rangePosition);
		}

		public function setValue( val:Number ):void {

			var pow:Number = Math.pow( 10, _numDecimals );
			var num:Number = Math.round( pow * val ) / pow;
			_sliderValueLabel.text = String( num );
			_sliderValueLabel.width = _sliderValueLabel.textWidth + 10;
			_sliderValueLabel.height = 1.25 * _sliderValueLabel.textHeight;

			val = Math.max( Math.min( val, _maximum ), _minimum );
			_value = val;

			//MOVE SLIDER
			var valueRatio:Number = (val - _minimum) / rangeValue;
			handleView.x = _shiftX + _minPosX + rangePosition * valueRatio;

			dispatchEvent( new Event( SbSlider.CHANGE ) );
		}

		public function set numDecimals( value:uint ):void {
			if( _numDecimals < 1 ) {
				throw new Error( this, "value must be >= 1." );
			}
			_numDecimals = value;
		}

		public function setIdLabel( id:String ):void {
			_sliderIdLabel.text = String( id );
			_sliderIdLabel.width = 1.25 * _sliderIdLabel.textWidth;
			_sliderIdLabel.height = 1.25 * _sliderIdLabel.textHeight;
		}

		public function getIdLabel():String {
			return _sliderIdLabel.text;
		}

		public function getValue():Number {
			return _value;
		}

		private function valueToPosition( val:Number ):Number {
			var valueRatio:Number = (val - _minimum) / rangeValue;
			return  _minPosX + rangePosition * valueRatio;
		}

		public function get minimum():Number {
			return _minimum;
		}

		public function set minimum( minValue:Number ):void {
			_minimum = minValue;
		}

		public function get maximum():Number {
			return _maximum;
		}

		public function set maximum( maxValue:Number ):void {
			_maximum = maxValue;
		}

		public function get rangeValue():Number {
			return _maximum - _minimum;
		}

		public function get rangePosition():Number {
			return _maxPosX - _minPosX;
		}
	}
}
