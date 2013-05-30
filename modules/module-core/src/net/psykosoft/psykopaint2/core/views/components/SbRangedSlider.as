package net.psykosoft.psykopaint2.core.views.components {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Dictionary;

public class SbRangedSlider extends Sprite {
	// Declared in Fla.
	public var bgView:Sprite; //TODO: if not used in the future, remove and use graphic directly from the fla
	public var leftHandleView:Sprite;
	public var rightHandleView:Sprite;
	public var rangeView:MovieClip;

	/*private var _limitForHandle:Dictionary;

	 private var _minPosX:Number = 70;
	 private var _maxPosX:Number = 360;

	 private var _selected:Sprite;
	 private var _nonSelected:Sprite;
	 private var _mouseDown:Boolean = false;
	 private var _mouseDownOnRange:Boolean = false;
	 private var _stage:Stage;
	 private var _clickOffset:Number;
	 private var _handleDistance:Number;*/
	//private var _minDistance:Number = 20; //TODO: minimum distance between handles is currently managed from within fla

//		public static const CHANGE:String = "onChange"; // TODO: ojo que no se estaba disparando el evento, tarde un rato largo en encontrar el bug, al probar un componente hay que probar -todas- sus funcionalidades
//		public static const STOP_DRAG:String = "STOP_DRAG"; // TODO: borrar si no se usa
	// TODO: de hecho, reemplazar estos por Event.CHANGE

	/*private function onRangeViewMouseDown(event:MouseEvent):void {
	 _mouseDownOnRange = true;
	 _clickOffset = mouseX - leftHandleView.x;
	 _handleDistance = rightHandleView.x - leftHandleView.x;
	 }*/


	/*public function dispose():void {
	 leftHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onLeftHandleMouseDown );
	 rightHandleView.removeEventListener( MouseEvent.MOUSE_DOWN, onRightHandleMouseDown );
	 _stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
	 _stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
	 }*/

	/*private function onLeftHandleMouseDown( event:MouseEvent ):void {
	 _selected = leftHandleView;
	 _clickOffset = mouseX - _selected.x;
	 _nonSelected = rightHandleView;
	 _mouseDown = true;
	 }*/

	/*private function onRightHandleMouseDown( event:MouseEvent ):void {
	 _selected = rightHandleView;
	 _clickOffset = mouseX - _selected.x;
	 _nonSelected = leftHandleView;
	 _mouseDown = true;
	 }*/

	/*private function onStageMouseMove( event:MouseEvent ):void {
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
	 }*/

	/*private function onStageMouseUp( event:MouseEvent ):void {
	 _selected = null;
	 _nonSelected = null;
	 _mouseDown = false;
	 _mouseDownOnRange = false;
	 }*/

	/*public function setValues( val1:Number, val2:Number ):void {
	 setValue( val1, 0 );
	 setValue( val2, 1 );
	 }*/

	/*public function setValue( val:Number, index:int = 0 ):void {

	 //SET VALUE WITHIN BOUNDS
	 val = Math.max( Math.min( val, _maxValue ), _minValue );

	 var pow:Number = Math.pow( 10, _numLabelsDecimals );
	 var num:Number = Math.round( pow * val ) / pow;

	 // TODO: posicionar handles

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

	 dispatchEvent( new Event( SbRangedSlider.CHANGE ) );
	 }*/

	private var _initialLeftHandleX:Number;
	private var _initialRightHandleX:Number;
	private var _maxDistanceBetweenHandles:Number;
	private var _range:Number;
	private var _minValue:Number = 0;
	private var _maxValue:Number = 1;
	private var _value1:Number = 0;
	private var _value2:Number = 1;
	private var _numLabelsDecimals:uint = 1;
	private var _labelLeft:TextField;
	private var _labelRight:TextField;
	private var _label:TextField;
	private var _mouseIsDown:Boolean;
	private var _handleBeingDragged:Sprite;
	private var _handleNotBeingDragged:Sprite;

	// ---------------------------------------------------------------------
	// Initialization.
	// ---------------------------------------------------------------------

	public function SbRangedSlider() {
		super();

		_initialLeftHandleX = leftHandleView.x;
		_initialRightHandleX = rightHandleView.x;

		_maxDistanceBetweenHandles = rightHandleView.x - leftHandleView.y;

		rangeView.stop();
		updateRangeView();

		initLabels();

		leftHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
	 	rightHandleView.addEventListener( MouseEvent.MOUSE_DOWN, onHandleMouseDown );
	 	rangeView.addEventListener( MouseEvent.MOUSE_DOWN, onRangeViewMouseDown );

		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}

	private function initLabels():void {

		_labelLeft = new TextField();
		_labelRight = new TextField();
		_label = new TextField();
		_labelLeft.x = 45;
		_labelLeft.y = 15;
		_labelRight.x = 415;
		_labelRight.y = 15;
		_label.y = 40;
		_label.x = 200;

		_labelLeft.width = _labelLeft.height = 1;
		_labelRight.width = _labelRight.height = 1;
		_label.width = _label.height = 1;

		_labelRight.mouseEnabled = false;
		_labelLeft.mouseEnabled = false;
		_label.mouseEnabled = false;
		_labelRight.selectable = false;
		_labelLeft.selectable = false;
		_label.selectable = false;

		addChild(_labelRight);
		addChild(_labelLeft);
		addChild(_label);
	}

	// ---------------------------------------------------------------------
	// Listeners.
	// ---------------------------------------------------------------------

	private function onRangeViewMouseDown(event:MouseEvent):void {
		// TODO...
	}

	private function onHandleMouseDown(event:MouseEvent):void {
		_mouseIsDown = true;
		_handleBeingDragged = event.target as Sprite;
		_handleNotBeingDragged = _handleBeingDragged == leftHandleView ? rightHandleView : leftHandleView;
	}

	private function onAddedToStage( event:Event ):void {
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
	 	stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
	}

	private function onStageMouseMove(event:MouseEvent):void {
		if( _mouseIsDown ) {

			_handleBeingDragged.x = mouseX;

			// Updates values from handle positions.
			var dx:Number;
			var ratio:Number;
			if( _handleBeingDragged == leftHandleView ) {
				dx = leftHandleView.x - _initialLeftHandleX;
				ratio = dx / _maxDistanceBetweenHandles;
				_value1 = ratioToValue( ratio );
			}
			else {
				dx = rightHandleView.x - _initialLeftHandleX;
				ratio = dx / _maxDistanceBetweenHandles;
				_value2 = ratioToValue( ratio );
			}

			updateRangeView();
		}
	}

	private function onStageMouseUp(event:MouseEvent):void {
		_mouseIsDown = false;
	}

	// ---------------------------------------------------------------------
	// Internal.
	// ---------------------------------------------------------------------

	private function updateHandles():void {
		// TODO: check collisions
	}

	private function updateRangeView():void {
		var deltaRatio:Number = valueToRatio(_value2) - valueToRatio(_value1);
		var frame:uint = Math.floor( deltaRatio * 100 );
		rangeView.gotoAndStop(frame);
		rangeView.x = _initialLeftHandleX + valueToRatio(_value1) * _maxDistanceBetweenHandles;
	}

	// Returns 0 -> 1
	private function valueToRatio(val:Number):Number {
		return ( val - _minValue ) / _range;
	}

	// Expects 0 -> 1
	private function ratioToValue(ratio:Number):Number {
		return ratio * _range + _minValue;
	}

	// ---------------------------------------------------------------------
	// Setters & getters.
	// ---------------------------------------------------------------------

	public function set minValue(minValue:Number):void {
		_minValue = minValue;
		_range = _maxValue - _minValue;
	}

	public function set maxValue(maxValue:Number):void {
		_maxValue = maxValue;
		_range = _maxValue - _minValue;
	}

	public function get range():Number {
		return _range;
	}

	public function set numDecimals(value:uint):void {
		if (_numLabelsDecimals < 1) {
			throw new Error(this, "value must be >= 1.");
		}
		_numLabelsDecimals = value;
	}

	public function set value1(value:Number):void {
		_value1 = Math.max(Math.min(value, _maxValue), _minValue);
		leftHandleView.x = _initialLeftHandleX + valueToRatio(_value1) * _maxDistanceBetweenHandles;
		updateRangeView();
		updateHandles();
	}

	public function set value2(value:Number):void {
		_value2 = Math.max(Math.min(value, _maxValue), _minValue);
		rightHandleView.x = _initialLeftHandleX + valueToRatio(_value2) * _maxDistanceBetweenHandles;
		updateRangeView();
		updateHandles();
	}

	public function get value1():Number {
		return _value1;
	}

	public function get value2():Number {
		return _value2;
	}

	public function set label(id:String):void {
		_label.text = String(id);
		_label.width = 1.25 * _label.textWidth;
		_label.height = 1.25 * _label.textHeight;
	}

	public function get label():String {
		return _label.text;
	}
}
}