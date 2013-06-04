package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import flashx.textLayout.formats.TextAlign;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.HItemScroller;
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
		private var _showing:Boolean = true;
		private var _needGapCheck:Boolean = true;

		private const BUTTON_GAP_X:Number = 8;
		private const BG_HEIGHT:uint = 200;
		private const SCROLLER_DISTANCE_FROM_BOTTOM:uint = 100;

		public var buttonClickedCallback:Function;
		public var shownSignal:Signal;
		public var showingSignal:Signal;
		public var hidingSignal:Signal;
		public var hiddenSignal:Signal;
		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;

		public function SbNavigationView() {
			super();
			shownSignal = new Signal();
			hidingSignal = new Signal();
			showingSignal = new Signal();
			hiddenSignal = new Signal();
			scrollingStartedSignal = new Signal();
			scrollingEndedSignal = new Signal();
			_leftButton = leftBtnSide.getChildByName( "btn" ) as SbButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as SbButton;
			hide( 0.01 );
		}

		override protected function onSetup():void {

			_leftButton.setLabelType( ButtonLabelType.LEFT );
			_rightButton.setLabelType( ButtonLabelType.RIGHT );

			_leftButton.setTextAlign( TextAlign.LEFT );
//			_leftButton.useLabelBg( true );
			_leftButton.autoCenterLabel( false );
			_leftButton.displaceLabelTf( -20, -15 );
			_leftButton.displaceLabelBg( -27, -10 );

			_rightButton.setTextAlign( TextAlign.RIGHT );
//			_rightButton.useLabelBg( true );
			_rightButton.autoCenterLabel( false );
			_rightButton.displaceLabelTf( -35, -15 );
			_rightButton.displaceLabelBg( -15, -5 );

			_scroller = new HItemScroller();
			_scroller.visibleHeight = 130;
			_scroller.visibleWidth = 1024;
			_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
			_scroller.positionManager.minimumThrowingSpeed = 15;
			_scroller.positionManager.frictionFactor = 0.85;
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
			if( !_showing ) return;
			hidingSignal.dispatch();
			_showing = false;
			_animating = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, time, { y: BG_HEIGHT + 50, onComplete: onHideAnimatedComplete, ease:Expo.easeInOut } );
		}
		private function onHideAnimatedComplete():void {
			hiddenSignal.dispatch();
			this.visible = false;
			_animating = false;
		}

		public function show():void {
			if( _animating ) return;
			if( _showing ) return;
			_showing = true;
			_animating = true;
			showingSignal.dispatch();
			this.visible = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 0.5, { y: 0, onComplete: onShowAnimatedComplete, ease:Expo.easeInOut } );
		}
		private function onShowAnimatedComplete():void {
			_animating = false;
			shownSignal.dispatch();
		}

		public function updateSubNavigation( subNavType:Class ):void {

			if( subNavType == null ) return;

			enable();

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
			else {
				visible = true;
			}

			// Create new view.
			_currentSubNavView = new subNavType();
			_currentSubNavView.setNavigation( this );
			_currentSubNavView.enable();
			addChild( _currentSubNavView );
		}

		public function evaluateInteractionStart():void {
			_scroller.evaluateInteractionStart();
		}

		public function evaluateInteractionEnd():void {
			_scroller.evaluateInteractionEnd();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function resetCenterButtons():void {
			if( !_scroller ) return;
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
			trace( this, "button clicked: " + button.labelText );
			var label:String = button.labelText;
			buttonClickedCallback( label );

			// Deselects all buttons except the one just clicked.
			if( _areButtonsSelectable && button != _leftButton && button != _rightButton ) {
				for( var i:Number = 0; i < _centerButtons.length; ++i ) {
					_centerButtons[ i ].toggleSelect( false );
				}
				button.toggleSelect( true );
			}
		}

		// TODO: this assumes that side buttons will always be set before center buttons, which is not enforced anywhere
		// and will cause edge gaps to be set incorrectly
		private function checkGap():void {
			// Decide scroller gaps according to the presence of side buttons.
			if( leftBtnSide.visible && rightBtnSide.visible ) {
				_scroller.leftGap = _scroller.rightGap = 150;
			}
			else if( leftBtnSide.visible && !rightBtnSide.visible ) {
				_scroller.leftGap = 150;
				_scroller.rightGap = 0;
			}
			else if( !leftBtnSide.visible && rightBtnSide.visible ) {
				_scroller.leftGap = 0;
				_scroller.rightGap = 150;
			}
			else {
				_scroller.leftGap = _scroller.rightGap = 0;
			}
			_needGapCheck = false;
		}

		// ---------------------------------------------------------------------
		// Methods called by SubNavigationViewBase.
		// ---------------------------------------------------------------------

		public function addCenterButton( label:String, iconType:String, labelType:String ):void {
			if( _needGapCheck ) checkGap();
			var specificButtonClass:Class = Class( getDefinitionByName( getQualifiedClassName( _leftButton ) ) );
			var btn:SbButton = new specificButtonClass();
			btn.labelText = label;
			btn.setIconType( iconType );
			btn.setLabelType( labelType );
			btn.x = _buttonPositionOffsetX;
			btn.y = _scroller.visibleHeight / 2;
			btn.addEventListener( MouseEvent.CLICK, onButtonClicked );
			// Defaults to 1st button as selected.
			if( _areButtonsSelectable ) {
				btn.isSelectable = true;
				if( _centerButtons.length == 0 ) {
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

		public function invalidateContent():void {
			_scroller.invalidateContent();
			_scroller.x = 1024 / 2 - _scroller.minWidth / 2;
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
