package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.formats.TextAlign;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.HItemScroller;
	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
	
	import org.osflash.signals.Signal;

	public class SbNavigationView extends ViewBase
	{
		// Declared in Flash.
		public var header:TextField;
		public var headerBg:Sprite;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;

		private var _leftButton:SbButton;
		private var _rightButton:SbButton;
		private var _currentSubNavView:SubNavigationViewBase;
		private var _buttonPositionOffsetX:Number;
		private var _centerButtons:Array;
		private var _scroller:HItemScroller;
		private var _areButtonsSelectable:Boolean;
		private var _animating:Boolean;
		private var _showing:Boolean;
		private var _needGapCheck:Boolean = true;

		private var _onReactiveHide:Boolean;
		private var _reactiveHideMouseDownY:Number;
		private var _reactiveHideStackY:StackUtil;
		private var _targetReactiveY:Number;

		private var _hidden:Boolean;
		private var _bgHeight:uint = 250;

		private const BUTTON_GAP_X:Number = 8;
		private const SCROLLER_DISTANCE_FROM_BOTTOM:uint = 100;

		public var buttonClickedCallback:Function;
		public var shownSignal:Signal;
		public var showingSignal:Signal;
		public var hidingSignal:Signal;
		public var hiddenSignal:Signal;
		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;
		public var showHideUpdateSignal:Signal;

		public function SbNavigationView() {
			super();

			shownSignal = new Signal();
			hidingSignal = new Signal();
			showingSignal = new Signal();
			hiddenSignal = new Signal();
			scrollingStartedSignal = new Signal();
			scrollingEndedSignal = new Signal();
			showHideUpdateSignal = new Signal();

			_reactiveHideStackY = new StackUtil();
			_leftButton = leftBtnSide.getChildByName( "btn" ) as SbButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as SbButton;
			_bgHeight *= CoreSettings.GLOBAL_SCALING;
			_targetReactiveY = 768 * scaleX - _bgHeight;

			enable();

			// Starts hidden.
			visible = false;
			_hidden = true;
			y = _bgHeight;
		}

		override protected function onSetup():void {

			_leftButton.setLabelType( ButtonLabelType.LEFT );
			_rightButton.setLabelType( ButtonLabelType.RIGHT );

			_leftButton.setTextAlign( TextAlign.LEFT );
//			_leftButton.useLabelBg( true );
			_leftButton.autoCenterLabel( false );
			_leftButton.displaceLabelTf( 20, -15 );
			_leftButton.displaceLabelBg( -27, -10 );

			_rightButton.setTextAlign( TextAlign.RIGHT );
//			_rightButton.useLabelBg( true );
			_rightButton.autoCenterLabel( false );
			_rightButton.snapLabelToRight( true );
			_rightButton.displaceLabelTf( 10, -15 );
			_rightButton.displaceLabelBg( 128, -5 );

			_scroller = new HItemScroller();
			_scroller.visibleHeight = 130;
			_scroller.visibleWidth = 1024;
			_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
			_scroller.positionManager.minimumThrowingSpeed = 15;
			_scroller.positionManager.frictionFactor = 0.70;
			_scroller.interactionManager.throwInputMultiplier = 2;
			_scroller.motionStartedSignal.add( onCenterScrollerMotionStart );
			_scroller.motionEndedSignal.add( onCenterScrollerMotionEnd );
			addChildAt( _scroller, 1 );

			_leftButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			_rightButton.addEventListener( MouseEvent.CLICK, onButtonClicked );

			visible = false;
		}

		// ---------------------------------------------------------------------
		// Interface to be used by the view's mediator.
		// ---------------------------------------------------------------------

		public function toggle():void {
			if( _showing ) hide();
			else show();
		}

		public function hide( time:Number = 0.5 ):void {
			if( _animating ) return;
			if( !_onReactiveHide && !_showing ) return;
			trace( this, "hide" );
			hidingSignal.dispatch();
			_showing = false;
			_animating = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, time, { y: _bgHeight, onUpdate: onShowHideUpdate, onComplete: onHideAnimatedComplete, ease:Strong.easeOut } );
		}
		private function onHideAnimatedComplete():void {
			hiddenSignal.dispatch();
			visible = false;
			_animating = false;
			_hidden = true;
			_targetReactiveY = 768 * scaleX - _bgHeight * 0.2;
			NavigationCache.isHidden = true;
		}

		public function show():void {
			trace( this, "trying to show: animating: " + _animating + ", on reactive hide: " + _onReactiveHide + ", showing: " + _showing );
			if( _animating ) return;
			if( !_onReactiveHide && _showing ) return;
			trace( this, "show" );
			_showing = true;
			_animating = true;
			showingSignal.dispatch();
			this.visible = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 0.5, { y: 0, onUpdate: onShowHideUpdate, onComplete: onShowAnimatedComplete, ease:Strong.easeOut } );
		}
		private function onShowAnimatedComplete():void {
			_animating = false;
			shownSignal.dispatch();
			_hidden = false;
			_targetReactiveY = 768 * scaleX - _bgHeight;
			NavigationCache.isHidden = false;
		}

		private function onShowHideUpdate():void {
			showHideUpdateSignal.dispatch( y / _bgHeight );
		}

		public function updateSubNavigation( subNavType:Class ):void {

			if( subNavType == null ) return;

			trace( this, "updating sub-nav: " + subNavType );

			// Reset.
			_needGapCheck = true;
			header.visible = false;
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;
			_areButtonsSelectable = false;
			resetCenterButtons();
			_scroller.reset();

			// Disable old view.
			if( _currentSubNavView ) {
				_currentSubNavView.disable();
				_currentSubNavView.dispose();
				removeChild( _currentSubNavView );
				_currentSubNavView = null;
			}

			// Hide?
			if( !subNavType ) {
				visible = false;
				return;
			}
			else if( !_hidden ) {
				visible = true;
			}

			// Create new view.
			_currentSubNavView = new subNavType();
			_currentSubNavView.setNavigation( this );
			_currentSubNavView.enable();
			addChild( _currentSubNavView );
		}

		public function evaluateScrollingInteractionStart():void {
			if (!_hidden ) _scroller.evaluateInteractionStart();
		}

		public function evaluateScrollingInteractionEnd():void {
			_scroller.evaluateInteractionEnd();
		}

		public function jumpScrollerToSnapPointIndex( value:uint ):void {
			_scroller.positionManager.snapAtIndexWithoutEasing( value );
		}

		public function getScrollerPosition():Number {
			return _scroller.positionManager.position;
		}

		public function setScrollerPosition( value:Number ):void {
			_scroller.positionManager.position = value;
			_scroller.refreshToPosition();
		}

		public function evaluateReactiveHideStart():void {
			if( _animating || _onReactiveHide || stage.mouseY < _targetReactiveY) return;
			//if( _onReactiveHide ) return;
			//if( stage.mouseY < _targetReactiveY ) return; // reject interactions outside of the navigation area
			_onReactiveHide = true;
			if( _hidden ) {
				visible = true;
				y = _bgHeight;
				_reactiveHideMouseDownY = stage.mouseY - _bgHeight;
			}
			else {
				_reactiveHideMouseDownY = stage.mouseY;
			}
			_reactiveHideStackY.clear();
//			trace( this, "reactive hide start - values: " + _reactiveHideStackY.values() );
			TweenLite.killTweensOf( this );
			if( !hasEventListener( Event.ENTER_FRAME ) ) addEventListener( Event.ENTER_FRAME, onReactiveHideEnterFrame );
		}

		public function evaluateReactiveHideEnd():void {
			if( !_onReactiveHide ) return;
			if( hasEventListener( Event.ENTER_FRAME ) ) removeEventListener( Event.ENTER_FRAME, onReactiveHideEnterFrame );
			var speedY:Number = _reactiveHideStackY.getAverageDeltaDetailed();
//			trace( this, "reactive hide end, speed: " + speedY + ", values: " + _reactiveHideStackY.values() );
			if( speedY == 0 ) {
				if( y > _bgHeight / 2 ) hide();
				else show();
			}
			else {
				if( speedY > 0 ) hide();
				else show();
			}

			_onReactiveHide = false;
		}

		private function onReactiveHideEnterFrame( event:Event ):void {
//			trace( this, "reactive hide enterframe" );
			y = stage.mouseY - _reactiveHideMouseDownY;
			if( y > _bgHeight ) y = _bgHeight;
			if( y < 0 ) y = 0;
//			trace( this, "pushing value: " + y + ", index: " + _reactiveHideStackY.newestIndex );
			_reactiveHideStackY.pushValue( y );
			showHideUpdateSignal.dispatch( y / _bgHeight );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function resetCenterButtons():void {
			_buttonPositionOffsetX = _leftButton.width / 2;
			if( _centerButtons && _centerButtons.length > 0 ) {
				var len:uint = _centerButtons.length;
				for( var i:uint; i < len; ++i ) {
					var centerButton:SbButton = _centerButtons[ i ];
					centerButton.removeEventListener( MouseEvent.CLICK, onButtonClicked );
					centerButton.dispose();
					centerButton = null;
				}
			}
			_centerButtons = [];
		}

		private function onButtonClicked( event:MouseEvent ):void {

			if( _scroller.isActive ) return; // Reject clicks while the scroller is moving.

			var button:SbButton = event.target as SbButton;
			if( !button ) button = event.target.parent as SbButton;
			var label:String = button.labelText;
			trace( this, "button clicked: " + button.labelText );

			// Deselects all buttons except the one just clicked.
			if( _areButtonsSelectable && button != _leftButton && button != _rightButton ) {
				for( var i:Number = 0; i < _centerButtons.length; ++i ) {
					_centerButtons[ i ].toggleSelect( false );
				}
				button.toggleSelect( true );
			}

			buttonClickedCallback( label );
		}

		// TODO: this assumes that side buttons will always be set before center buttons, which is not enforced anywhere
		// and will cause edge gaps to be set incorrectly
		private function checkGap():void {
			// Decide scroller gaps according to the presence of side buttons.
			if( leftBtnSide.visible && rightBtnSide.visible ) {
				_scroller.leftGap =  60;
				_scroller.rightGap = 210;
			}
			else if( leftBtnSide.visible && !rightBtnSide.visible ) {
				_scroller.leftGap = 60;
				_scroller.rightGap = 60;
			}
			else if( !leftBtnSide.visible && rightBtnSide.visible ) {
				_scroller.leftGap = 10;
				_scroller.rightGap = 210;
			}
			else {
				_scroller.leftGap = _scroller.rightGap = 10;
			}
			_needGapCheck = false;
		}

		// ---------------------------------------------------------------------
		// Methods called by SubNavigationViewBase.
		// ---------------------------------------------------------------------

		public function addCenterButton( label:String, iconType:String, labelType:String, icon:Bitmap, autoSelect:Boolean = true ):void {
			if( _needGapCheck ) checkGap();

			var specificButtonClass:Class = Class( getDefinitionByName( getQualifiedClassName( _leftButton ) ) );
			var btn:SbButton = new specificButtonClass();
			btn.labelText = label;
			if( iconType != "" ) btn.setIconType( iconType );
			btn.setLabelType( labelType );
			btn.x = _buttonPositionOffsetX;
			btn.y = _scroller.visibleHeight / 2;
			if( icon ) btn.setIcon( icon );
			btn.addEventListener( MouseEvent.CLICK, onButtonClicked );
			// Defaults to 1st button as selected.
			if( _areButtonsSelectable ) {
				btn.isSelectable = true;
				if( autoSelect && _centerButtons.length == 0 ) {
					btn.toggleSelect( true );
				}
			}
			_scroller.addChild( btn );
			_centerButtons.push( btn );
			_buttonPositionOffsetX += 140 + BUTTON_GAP_X;
		}

		public function setLabel( value:String ):void {

			if( value == "" ) {
				header.visible = headerBg.visible = false;
				return;
			}
			else {
				header.visible = headerBg.visible = true;
			}

			header.text = value;
			header.visible = true;

			header.height = 1.25 * header.textHeight;
			header.width = 15 + header.textWidth;
			header.x = 1024 / 2 - header.width / 2;

			headerBg.width = header.width + 50;
			headerBg.x = 1024 / 2 - headerBg.width / 2 + 5;
		}

		public function setLeftButton( label:String ):void {
			_leftButton.labelText = label;
			_leftButton.visible = true;
			leftBtnSide.visible = true;
		}

		public function setRightButton( label:String ):void {
			_rightButton.labelText = label;
			_rightButton.visible = true;
			rightBtnSide.visible = true;
		}

		public function toggleLeftButtonVisibility( value:Boolean ):void {
			_leftButton.visible = value;
			leftBtnSide.visible = value;
			//TODO: might have to review gaps and snapPoints
		}

		public function toggleRightButtonVisibility( value:Boolean ):void {
			_rightButton.visible = value;
			rightBtnSide.visible = value;
			//TODO: might have to review gaps and snapPoints
		}

		public function invalidateContent():void {
			_scroller.invalidateContent();
			_scroller.x = 1024 / 2 - _scroller.minWidth / 2;

			if( leftBtnSide.visible && rightBtnSide.visible && _centerButtons.length <= 5) _scroller.scrollable = false;
			else if( leftBtnSide.visible && _centerButtons.length >= 6 ){
				_scroller.x += leftBtnSide.width / 2;
				_scroller.scrollable = true;
			}
			else if( rightBtnSide.visible && _centerButtons.length >= 6 ){
				_scroller.x -= rightBtnSide.width / 2;
				_scroller.scrollable = true;
			}
			else if ( _centerButtons.length >= 7 ) _scroller.scrollable = true;
			else _scroller.scrollable = false;

			_scroller.dock();
		}

		public function areButtonsSelectable( value:Boolean ):void {
			_areButtonsSelectable = value;
		}

		public function selectButtonWithLabel( value:String ):void {
			if( !_areButtonsSelectable ) return;
			for( var i:Number = 0; i < _centerButtons.length; ++i ) {
				var button:SbButton = _centerButtons[ i ];
				button.toggleSelect( button.labelText == value );
			}
		}
		
		public function selectButtonByIndex( index:int ):void {
			if( !_areButtonsSelectable ) return;
			for( var i:Number = 0; i < _centerButtons.length; ++i ) {
				_centerButtons[ i ].toggleSelect( i == index );
			}
		}

		// ---------------------------------------------------------------------
		// Handlers.
		// ---------------------------------------------------------------------

		private function onCenterScrollerMotionEnd():void {
			scrollingEndedSignal.dispatch();
		}

		private function onCenterScrollerMotionStart():void {
			scrollingStartedSignal.dispatch();
		}
	}
}
