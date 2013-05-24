package net.psykosoft.psykopaint2.core.views.components
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	public class SbRangedSlider extends Sprite
	{
		// Declared in Fla.
		public var bgView:Sprite;
		public var leftHandleView:Sprite;
		public var rightHandleView:Sprite;
		public var rangeView:MovieClip;

		private var _limitForHandle:Dictionary;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _minPosX:Number = 55;
		private var _maxPosX:Number = 368;
		private var _value1:Number = 0;
		private var _value2:Number = 1;
		private var _labelLeft:TextField;
		private var _labelRight:TextField;
		private var _idLabel:TextField;
		private var _numDecimals:uint = 1;
		private var _selected:Sprite;
		private var _nonSelected:Sprite;
		private var _mouseDown:Boolean;
		private var _stage:Stage;
		private var _clickOffset:Number;

		public static const CHANGE:String = "onChange";
		public static const STOP_DRAG:String = "STOP_DRAG";

		public function SbRangedSlider() {
			super();

            _labelLeft = new TextField();
			_labelRight = new TextField();
			_idLabel = new TextField();
			_labelLeft.x = 0;
			_labelRight.x = 185;
			_idLabel.y = 40;

            _labelLeft.width = _labelLeft.height = 1;
            _labelRight.width = _labelRight.height = 1;
            _idLabel.width = _idLabel.height = 1;

			_labelRight.mouseEnabled = false;
			_labelLeft.mouseEnabled = false;
			_idLabel.mouseEnabled = false;
			_labelRight.selectable = false;
			_labelLeft.selectable = false;
			_idLabel.selectable = false;

			addChild( _labelRight );
			addChild( _labelLeft );
			addChild( _idLabel );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

            rangeView.stop();

			leftHandleView.x = _minPosX + leftHandleView.width / 2;
			rightHandleView.x = _maxPosX + rightHandleView.width / 2;
            rangeView.x = leftHandleView.x + leftHandleView.width - 2;

			_limitForHandle = new Dictionary();
			_limitForHandle[ leftHandleView ] = new Point( _minPosX, rightHandleView.x );
			_limitForHandle[ rightHandleView ] = new Point( leftHandleView.x, _maxPosX );

			setValue( _value1, 0 );
			setValue( _value2, 1 );

			leftHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onLeftHandleMouseDown );
			rightHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onRightHandleMouseDown );

			_stage = stage;
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}


		public function dispose():void {
			leftHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onLeftHandleMouseDown );
			rightHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onRightHandleMouseDown );
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		private function onLeftHandleMouseDown( event:MouseEvent ):void {
			_selected = leftHandleView;
			_clickOffset = mouseX - _selected.x; // TODO: implement same offset logic in simple slider
			_nonSelected = rightHandleView;
			_mouseDown = true;
		}

		private function onRightHandleMouseDown( event:MouseEvent ):void {
			_selected = rightHandleView;
			_clickOffset = mouseX - _selected.x;
			_nonSelected = leftHandleView;
			_mouseDown = true;
		}

		private function onStageMouseMove( event:MouseEvent ):void {
			if( _mouseDown ) {

				var posX:Number = mouseX - _clickOffset;

				var slideValue:Number;
				var index:Number;

				var leftLimits:Point = _limitForHandle[ leftHandleView ];
				var rightLimits:Point = _limitForHandle[ rightHandleView ];

				leftLimits.y = rightHandleView.x - leftHandleView.width / 2;
				rightLimits.x = leftHandleView.x - rightHandleView.width / 2;

				var limit:Point = _limitForHandle[ _selected ];

				_selected.x = Math.max( Math.min( posX, limit.y ), limit.x );
//				_selected.x -= _selected.width / 2; // TODO: review this line

				index = ( _selected == leftHandleView ) ? 0 : 1;

				slideValue = positionToValue( posX );
				setValue( slideValue, index );

                repositionRange();
			}
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_selected = null;
			_nonSelected = null;
			_mouseDown = false;
		}

		public function setValues( val1:Number, val2:Number ):void {
			setValue( val1, 0 );
			setValue( val2, 1 );
		}

		public function setValue( val:Number, index:int = 0 ):void {

			//SET VALUE WITHIN BOUNDS
			val = Math.max( Math.min( val, _maxValue ), _minValue );

			var pow:Number = Math.pow( 10, _numDecimals );
			var num:Number = Math.round( pow * val ) / pow;

			if( index == 0 ) {
				_value1 = val;
				_labelLeft.text = String( num );
                _labelLeft.width = 1.25 * _labelLeft.textWidth;
			    _labelLeft.height = 1.25 * _labelLeft.textHeight;
			}
			else {
				_value2 = val;
				_labelRight.text = String( num );
                _labelRight.width = 1.25 * _labelRight.textWidth;
			    _labelRight.height = 1.25 * _labelRight.textHeight;
			}
		}

        private function repositionRange():void
		{
			rangeView.x = leftHandleView.x + leftHandleView.width - 2;
			rangeView.gotoAndStop( Math.min( Math.max( 100-int( (_value2-_value1)*100 ),0 ),99 ) );
			if( rangeView.currentFrame >= 99 ){
				rangeView.visible = false;
			}else { rangeView.visible = true; }

            trace("RANGE VIEW FRAME _________>>>>",_value2-_value1);
		}

		public function getValues():Array {
			return [ _value1, _value2 ];
		}

		private function positionToValue( posX:Number ):Number {
			var limitedPosX:Number = Math.max( Math.min( posX, _maxPosX ), _minPosX );
			return  _minValue + totalRangeOfValues * ((limitedPosX - _minPosX) / rangePosition);
		}

		private function valueToPosition( val:Number ):Number {
			var valueRatio:Number = (val - _minValue) / totalRangeOfValues;
			return  _minPosX + rangePosition * valueRatio;
		}

		private function positionToValueRight( posX:Number ):Number {
			return  _minValue + totalRangeOfValues * ((posX - _minPosX) / rangePosition);
		}

		private function valueToPositionRight( val:Number ):Number {
			var valueRatio:Number = (val - _minValue) / totalRangeOfValues;
			return  _minPosX + rangePosition * valueRatio;
		}

		public function get minValue():Number {
			return _minValue;
		}

		public function set minValue( minValue:Number ):void {
			_minValue = minValue;
		}

		public function get maxValue():Number {
			return _maxValue;
		}

		public function set maxValue( maxValue:Number ):void {
			_maxValue = maxValue;
		}

		public function get rangeValue():Number {
			return _value2 - _value1;
		}

		public function get totalRangeOfValues():Number {
			return _maxValue - _minValue;
		}

		public function get rangePosition():Number {
			return _maxPosX - _minPosX;
		}

		public function set numDecimals( value:uint ):void {
			if( _numDecimals < 1 ) {
				throw new Error( this, "value must be >= 1." );
			}
			_numDecimals = value;
		}

		public function setIdLabel( id:String ):void {
			_idLabel.text = String( id );
            _idLabel.width = 1.25 * _idLabel.textWidth;
			_idLabel.height = 1.25 * _idLabel.textHeight;
		}
	}
}
