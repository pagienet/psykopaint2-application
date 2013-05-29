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
		public var bgView:Sprite; //TODO: if not used in the future, remove and use graphic directly from the fla
		public var leftHandleView:Sprite;
		public var rightHandleView:Sprite;
		public var rangeView:MovieClip;

		private var _limitForHandle:Dictionary;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _minPosX:Number = 70;
		private var _maxPosX:Number = 360;
		private var _value1:Number = 0;
		private var _value2:Number = 1;
		private var _labelLeft:TextField;
		private var _labelRight:TextField;
		private var _idLabel:TextField;
		private var _numDecimals:uint = 1;
		private var _selected:Sprite;
		private var _nonSelected:Sprite;
		private var _mouseDown:Boolean = false;
		private var _mouseDownOnRange:Boolean = false;
		private var _stage:Stage;
		private var _clickOffset:Number;
		private var _handleDistance:Number;
        //private var _minDistance:Number = 20; //TODO: minimum distance between handles is currently managed from within fla

		public static const CHANGE:String = "onChange";
		public static const STOP_DRAG:String = "STOP_DRAG";

		public function SbRangedSlider() {
			super();

            _labelLeft = new TextField();
			_labelRight = new TextField();
			_idLabel = new TextField();
			_labelLeft.x = 45;
			_labelLeft.y = 15;
			_labelRight.x = 415;
			_labelRight.y = 15;
			_idLabel.y = 40;
			_idLabel.x = 200;

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

			leftHandleView.x = _minPosX;
			rightHandleView.x = _maxPosX;
            rangeView.x = leftHandleView.x + leftHandleView.width - 2;

			_limitForHandle = new Dictionary();
			_limitForHandle[ leftHandleView ] = new Point( _minPosX, rightHandleView.x );
			_limitForHandle[ rightHandleView ] = new Point( leftHandleView.x, _maxPosX );

			setValue( _value1, 0 );
			setValue( _value2, 1 );

			leftHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onLeftHandleMouseDown );
			rightHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onRightHandleMouseDown );
			rangeView.addEventListener( MouseEvent.MOUSE_DOWN, onRangeViewMouseDown );

			_stage = stage;
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

        private function onRangeViewMouseDown(event:MouseEvent):void {
            _mouseDownOnRange = true;
            _clickOffset = mouseX - leftHandleView.x;
            _handleDistance = rightHandleView.x - leftHandleView.x;
        }


		public function dispose():void {
			leftHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onLeftHandleMouseDown );
			rightHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onRightHandleMouseDown );
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
		}

		private function onLeftHandleMouseDown( event:MouseEvent ):void {
			_selected = leftHandleView;
			_clickOffset = mouseX - _selected.x;
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

				var slideValueSelected:Number;
				var slideValueNonSelected:Number;
				var indexSelected:Number;
				var indexNonSelected:Number;

				var leftLimits:Point = _limitForHandle[ leftHandleView ];
				var rightLimits:Point = _limitForHandle[ rightHandleView ];

				leftLimits.y = rightHandleView.x;
				rightLimits.x = leftHandleView.x;

				var limitSelected:Point = _limitForHandle[ _selected ];
                var limitNonSelected:Point = _limitForHandle[ _nonSelected ];

				_selected.x = Math.max( Math.min( posX, limitSelected.y ), limitSelected.x );

                if( _selected.x == _nonSelected.x ){
                    rangeView.visible = false;

                    _nonSelected.x = Math.max( Math.min( posX, limitNonSelected.y ), limitNonSelected.x );
                    indexNonSelected = ( _nonSelected == leftHandleView ) ? 0 : 1;
                    slideValueNonSelected = positionToValue( _nonSelected.x ); //TODO: make sure this is the value we should be passing
				    setValue( slideValueNonSelected, indexNonSelected );
                }
                else{
                    rangeView.visible = true;
                }

				indexSelected = ( _selected == leftHandleView ) ? 0 : 1;

				slideValueSelected = positionToValue( _selected.x ); //TODO: make sure this is the value we should be passing
				setValue( slideValueSelected, indexSelected );

                repositionRange();
			}

            if( _mouseDownOnRange ) {

                var leftValue:Number;
                var rightValue:Number;

                var leftPosX:Number = Math.max( Math.min( mouseX - _clickOffset, _maxPosX - _handleDistance ), _minPosX );
                leftHandleView.x = leftPosX;

                rangeView.x = leftPosX + leftHandleView.width - 2;

                var rightPosX:Number = Math.max( Math.min( leftHandleView.x + _handleDistance, _maxPosX ), _minPosX + _handleDistance );
                rightHandleView.x = rightPosX;

                leftValue = positionToValue( leftPosX );
                rightValue = positionToValue( rightPosX );
                setValues( leftValue, rightValue );
            }
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_selected = null;
			_nonSelected = null;
			_mouseDown = false;
			_mouseDownOnRange = false;
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
                _labelLeft.width = _labelLeft.textWidth + 10;
			    _labelLeft.height = 1.25 * _labelLeft.textHeight;
			}
			else {
				_value2 = val;
				_labelRight.text = String( num );
                _labelRight.width = _labelRight.textWidth + 10;
			    _labelRight.height = 1.25 * _labelRight.textHeight;
			}
		}

        private function repositionRange():void
		{
			rangeView.x = leftHandleView.x + leftHandleView.width - 2;
            var frame:Number =  Math.min( Math.max( 100-int( ((_value2-_value1)-_minValue)*100 ),0 ),99 );
			rangeView.gotoAndStop( frame );
//			if( rangeView.currentFrame >= 99 ){
//				rangeView.visible = false;
//			}else { rangeView.visible = true; }

		}

		public function getValues():Array {
			return [ _value1, _value2 ];
		}

		private function positionToValue( posX:Number ):Number {
			var limitedPosX:Number = Math.max( Math.min( posX, _maxPosX ), _minPosX );    //TODO: go through value managing methods, make sure they are ok
			return  _minValue + totalRangeOfValues * ((posX - _minPosX) / rangePosition);
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

		public function getIdLabel():String {
			return _idLabel.text;
		}
	}
}