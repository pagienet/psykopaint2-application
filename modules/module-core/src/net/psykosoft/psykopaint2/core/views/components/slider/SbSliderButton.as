package net.psykosoft.psykopaint2.core.views.components.slider
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Bitmap;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class SbSliderButton extends Sprite
	{
		// Declared in Flash.
		public var button:NavigationButton;
		public var leftEar:Sprite;
		public var rightEar:Sprite;

		private var _rightEarOpenX:Number;
		private var _leftEarOpenX:Number;
		private var _labelText:String;
		private var _value:Number;
		private var _sliding:Boolean;
		private var _earContainer:Sprite;
		private var _ratio:Number;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _valueRange:Number = 1;
		private var _labelMode:int = 1;
		private var _digits:int = 2;
		private var _earContainerX:Number = 0;
		private var _mouseDownX:Number;
		private var _changeEvt:Event;
		private var _earContainerXOnMouseDown:Number = 0;

		private const EAR_MOTION_RANGE:Number = 50;
		private const EAR_ANIMATION_TIME:Number = 0.2;

		public static var LABEL_VALUE:int = 0;
		public static var LABEL_PERCENT:int = 1;
		public static var LABEL_DEGREES:int = 2;

		public function SbSliderButton() {
			super();
			setup();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function dispose():void {

			stopSliding();

			button.removeEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			button.dispose();

			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		// ----------------------------
		// Construction/destruction.
		// ----------------------------

		private function setup():void {

			_value = _ratio = 0;

			_changeEvt = new Event( Event.CHANGE );

			_leftEarOpenX = leftEar.x;
			_rightEarOpenX = rightEar.x;

			leftEar.x = 0;
			rightEar.x = 0;

			_earContainer = new Sprite();
			_earContainer.visible = false;
			_earContainer.addChild( leftEar );
			_earContainer.addChild( rightEar );
			addChildAt( _earContainer, 0 );

			button.labelText = "";
		}

		private function postSetupAfterStageIsAvailable():void {
			button.addEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		// -----------------------
		// Label.
		// -----------------------

		private function updateLabelFromValue():void {
			switch( _labelMode ) {
				case LABEL_VALUE:
					button.labelText = formatLabel( _value );
					break;
				case LABEL_PERCENT:
					button.labelText = formatLabel( _ratio * 100, "%" );
					break;
				case LABEL_DEGREES:
					button.labelText = formatLabel( _value, "°" );
					break;
			}
		}

		private function formatLabel( value:Number, suffix:String = "" ):String {
			return String( int( value * Math.pow( 10, _digits ) + 0.5 ) / Math.pow( 10, _digits ) ) + suffix;
		}

		// -----------------------
		// Enterframe.
		// -----------------------

		private function startSliding():void {
			if( _sliding ) return;
			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			updateLabelFromValue();
			_sliding = true;
		}

		private function stopSliding():void {
			if( !_sliding ) return;
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			button.labelText = _labelText;
			_sliding = false;
		}

		private function update():void {
			if( !_sliding ) return;
			updateEarsFromMouse();
			updateRatioFromEars();
			updateValueFromRatio();
			updateLabelFromValue();
			dispatchEvent( _changeEvt );
		}

		// -----------------------
		// Conversions.
		// -----------------------

		private function updateEarsFromMouse():void {
			var dx:Number = mouseX - _mouseDownX;
			_earContainerX = _earContainerXOnMouseDown + dx;
			if( _earContainerX < -EAR_MOTION_RANGE ) _earContainerX = -EAR_MOTION_RANGE;
			if( _earContainerX >  EAR_MOTION_RANGE ) _earContainerX =  EAR_MOTION_RANGE;
			_earContainer.x = _earContainerX;
		}

		private function updateRatioFromEars():void {
			_ratio = 0.5 * ( _earContainerX / EAR_MOTION_RANGE ) + 0.5;
		}

		private function updateRatioFromValue():void {
			_ratio = ( _value - _minValue ) / _valueRange;
		}

		private function updateValueFromRatio():void {
			_value = _ratio * _valueRange + _minValue;
		}

		private function updateEarsFromRatio():void {
			_earContainer.x = _earContainerX = EAR_MOTION_RANGE * ( 2 * _ratio - 1 );
		}

		// -----------------------
		// Tweens.
		// -----------------------

		private function showEars():void {
			killEarTweens();
			_earContainer.visible = true;
			TweenLite.to( leftEar, EAR_ANIMATION_TIME, { x: _leftEarOpenX, ease: Strong.easeOut } );
			TweenLite.to( rightEar, EAR_ANIMATION_TIME, { x: _rightEarOpenX, ease: Strong.easeOut } );
			TweenLite.to( _earContainer, EAR_ANIMATION_TIME, { x: _earContainerX, ease: Strong.easeOut } );
		}

		private function hideEars():void {
			killEarTweens();
			TweenLite.to( leftEar, EAR_ANIMATION_TIME, { x: 0, ease: Strong.easeIn, onComplete: onEarsHideComplete } );
			TweenLite.to( rightEar, EAR_ANIMATION_TIME, { x: 0, ease: Strong.easeIn } );
			TweenLite.to( _earContainer, EAR_ANIMATION_TIME, { x: 0, ease: Strong.easeIn } );
		}

		private function onEarsHideComplete():void {
			_earContainer.visible = false;
		}

		private function killEarTweens():void {
			TweenLite.killTweensOf( leftEar );
			TweenLite.killTweensOf( rightEar );
			TweenLite.killTweensOf( _earContainer );
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function get selected():Boolean {
			return button.selected;
		}

		public function set selected( value:Boolean ):void {
			button.selected = value;
		}

		public function get selectable():Boolean {
			return button.selectable;
		}

		public function set selectable( value:Boolean ):void {
			button.selectable = value;
		}

		public function get iconBitmap():Bitmap {
			return button.iconBitmap;
		}

		public function set iconBitmap( value:Bitmap ):void {
			button.iconBitmap = value;
		}

		public function get iconType():String {
			return button.iconType;
		}

		public function set iconType( value:String ):void {
			button.iconType = value;
		}

		public function get id():String {
			return button.id;
		}

		public function set id( value:String ):void {
			button.id = value;
		}

		public function get labelMode():int {
			return _labelMode;
		}

		public function set labelMode( value:int ):void {
			_labelMode = value;
		}

		public function set minValue( minValue:Number ):void {
			_minValue = minValue;
			_valueRange = _maxValue - _minValue;
			updateRatioFromValue();
		}

		public function set maxValue( maxValue:Number ):void {
			_maxValue = maxValue;
			_valueRange = _maxValue - _minValue;
			updateRatioFromValue();
		}

		public function get labelText():String {
			return _labelText;
		}

		public function set labelText( value:String ):void {
			_labelText = value;
			button.labelText = value;
		}

		public function set value( value:Number ):void {
			_value = value;
			updateRatioFromValue();
			updateEarsFromRatio();
			dispatchEvent( _changeEvt );
		}

		public function get value():Number {
			return _value;
		}

		public function get digits():int {
			return _digits;
		}

		public function set digits( value:int ):void {
			_digits = value;
		}

		// ---------------------------------------------------------------------
		// Event listeners.
		// ---------------------------------------------------------------------

		private function onEnterFrame( event:Event ):void {
			update();
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			postSetupAfterStageIsAvailable();
		}

		private function onBtnMouseDown( event:MouseEvent ):void {
			_mouseDownX = mouseX;
			_earContainerXOnMouseDown = _earContainerX;
			startSliding();
			showEars();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			stopSliding();
			hideEars();
		}
	}
}
