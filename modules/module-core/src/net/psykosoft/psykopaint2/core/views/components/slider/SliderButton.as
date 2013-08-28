package net.psykosoft.psykopaint2.core.views.components.slider
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.core.views.components.previews.AbstractPreview;
	import net.psykosoft.psykopaint2.core.views.components.previews.PreviewIconFactory;
	

	public class SliderButton extends Sprite
	{
		// Declared in Flash.
		public var button:NavigationButton;
		public var leftEar:Sprite;
		public var rightEar:Sprite;
		public var previewHolder:Sprite;
		

		private var _rightEarOpenX:Number;
		private var _leftEarOpenX:Number;
		private var _previewHolderOpenY:Number;
		
		private var _labelText:String;
		private var _defaultLabelText:String;
		private var _previewID:String;
		private var _value:Number;
		private var _sliding:Boolean;
		private var _earContainer:Sprite;
		private var _ratio:Number;
		private var _minValue:Number = 0;
		private var _maxValue:Number = 1;
		private var _valueRange:Number = 1;
		private var _labelMode:int = 1;
		private var _digits:int = 0;
		private var _earContainerX:Number = 0;
		private var _mouseDownX:Number;
		private var _changeEvt:Event;
		private var _earContainerXOnMouseDown:Number = 0;
		private var _stage:Stage;

		private var _valueHasChanged:Boolean;
		private var _checkClosingTap:Boolean;
		
		private var _previewIcon:AbstractPreview;
		
		private const EAR_MOTION_RANGE:Number = 50;
		private const EAR_ANIMATION_TIME:Number = 0.2;
		private const PREVIEW_ANIMATION_TIME:Number = 0.2;
		private const PREVIEW_ICON_OFFSET_X:Number = 64;
		private const PREVIEW_ICON_OFFSET_Y:Number = 64;

		public static var LABEL_VALUE:int = 0;
		public static var LABEL_PERCENT:int = 1;
		public static var LABEL_DEGREES:int = 2;

		public function SliderButton() {
			super();
			setup();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function dispose():void {

			stopSliding();
			_earContainer.removeEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			button.removeEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			button.dispose();

			if( _stage ) {
				_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			}

			_stage = null;
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
			
			_previewHolderOpenY = previewHolder.y;

			_earContainer = new Sprite();
			_earContainer.visible = false;
			_earContainer.addChild( rightEar );
			_earContainer.addChild( leftEar );
			addChildAt( _earContainer, 0 );

			button.labelText = "";

			
			
			
			_stage = stage;
			
			_valueHasChanged = false;
			_checkClosingTap = false;
		}

		private function postSetupAfterStageIsAvailable():void {
			button.addEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			_earContainer.addEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
			
		}

		// -----------------------
		// Label.
		// -----------------------

		public function updateLabelFromValue():void {
			switch( _labelMode ) {
				case LABEL_VALUE:
					button.labelText = formatLabel( value);
					break;
				case LABEL_PERCENT:
					button.labelText = formatLabel(  _ratio * 100, "%" );
					break;
				case LABEL_DEGREES:
					button.labelText = formatLabel(  value, "°" );
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
			//updateLabelFromValue();
			_sliding = true;
		}

		private function stopSliding():void {
			if( !_sliding ) return;
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			button.labelText = _defaultLabelText;
			_sliding = false;
		}

		private function update():void {
			if( !_sliding ) return;
			updateEarsFromMouse();
			updateRatioFromEars();
			updateValueFromRatio();
			//updateLabelFromValue();
			updatePreviewIconFromRatio();
			dispatchEvent( _changeEvt );
		}

		// -----------------------
		// Conversions.
		// -----------------------

		private function updateEarsFromMouse():void {
			var dx:Number = mouseX - _mouseDownX;
			_valueHasChanged ||= (dx != 0);
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
		
		private function updatePreviewIconFromRatio():void {
			if ( _previewIcon ) _previewIcon.ratio = _ratio;
		}

		// -----------------------
		// Tweens.
		// -----------------------

		private function showEars():void {
			killEarTweens();
			_earContainer.visible = true;
			TweenLite.to( leftEar, EAR_ANIMATION_TIME, { x: _leftEarOpenX, ease: Strong.easeOut, onComplete: onEarsShowComplete  } );
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
		
		private function onEarsShowComplete():void {
			//showPreviewHolder();
		}
		
		private function killEarTweens():void {
			TweenLite.killTweensOf( leftEar );
			TweenLite.killTweensOf( rightEar );
			TweenLite.killTweensOf( _earContainer );
		}
		
		private function showPreviewHolder():void {
			killPreviewTweens();
			button.showIcon( false );
			previewHolder.visible = true;
			TweenLite.to( previewHolder, PREVIEW_ANIMATION_TIME, { y: _previewHolderOpenY - 120, ease: Strong.easeOut } );
			_previewIcon.x = PREVIEW_ICON_OFFSET_X;
			_previewIcon.y = PREVIEW_ICON_OFFSET_Y;
			previewHolder.addChild(_previewIcon);
			
			
		}
		
		private function hidePreviewHolder():void {
			killPreviewTweens();
			TweenLite.to( previewHolder, PREVIEW_ANIMATION_TIME, { y: _previewHolderOpenY, ease: Strong.easeIn, onComplete: onPreviewHideComplete } );
		}

		private function onPreviewHideComplete():void {
			_previewIcon.x = 0;
			_previewIcon.y = 0;
			
			button.addChildAt(_previewIcon,1);
			
			previewHolder.visible = false;
			button.showIcon( true );
			hideEars();
		}
		
		private function killPreviewTweens():void {
			TweenLite.killTweensOf( previewHolder );
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
		
		
		public function get previewID():String {
			return _previewID;
		}
		
		public function set previewID( value:String ):void {
			_previewID = value;
			
			if ( _previewIcon != null && _previewIcon.parent != null)
			{
				_previewIcon.parent.removeChild(_previewIcon);
				_previewIcon = null;
			}
			_previewIcon = PreviewIconFactory.getPreviewIcon(previewID);
			_previewIcon.mouseEnabled = _previewIcon.mouseChildren = false;
			_previewIcon.x = 0;
			_previewIcon.y = 0;
			_previewIcon.scaleX = _previewIcon.scaleY = 0.5;
			button.addChildAt(_previewIcon,1);
			
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
		
		public function get defaultLabelText():String {
			return _defaultLabelText;
		}
		
		public function set defaultLabelText( value:String ):void {
			_defaultLabelText = value;
		}

		public function set value( value:Number ):void {
			_value = value;
			updateRatioFromValue();
			updateEarsFromRatio();
			updatePreviewIconFromRatio();
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
			if ( !_valueHasChanged && !_checkClosingTap)
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				showEars();
				showPreviewHolder();
			}
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			var isOver:Boolean = this.hitTestPoint(stage.mouseX, stage.mouseY,true);
			stopSliding();
			if ( _valueHasChanged || _checkClosingTap || !isOver)
			{
				//hideEars();
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				hidePreviewHolder();
				_valueHasChanged = false;
				_checkClosingTap = false;
			} else {
				_checkClosingTap = true;
			}
		}
	}
}
