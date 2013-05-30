package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.HItemScroller;
	import net.psykosoft.psykopaint2.base.ui.components.HSnapScroller;
	import net.psykosoft.psykopaint2.core.views.components.NavigationButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.components.SbNavigationButton;

	import org.osflash.signals.Signal;

	public class SbNavigationView extends ViewBase
	{
		// Declared in Flash.
		public var header:TextField;
		public var headerBg:Sprite;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;

		private var _leftButton:SbNavigationButton;
		private var _rightButton:SbNavigationButton;
		private var _currentSubNavView:SubNavigationViewBase;
		private var _buttonPositionOffsetX:Number;
		private var _centerButtons:Array;
		private var _centerComponentsScroller:HItemScroller;
		private var _areButtonsSelectable:Boolean;
		private var _animating:Boolean;
		private var _showing:Boolean = true;

		private const ELEMENT_GAP:Number = 15;
		private const BUTTON_GAP_X:Number = 8;
		private const BG_HEIGHT:uint = 200;

		public var buttonClickedCallback:Function;
		public var shownAnimatedSignal:Signal;
		public var hiddenAnimatedSignal:Signal;
		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;

		public function SbNavigationView() {
			super();
			shownAnimatedSignal = new Signal();
			hiddenAnimatedSignal = new Signal();
			scrollingStartedSignal = new Signal();
			scrollingEndedSignal = new Signal();
			_leftButton = leftBtnSide.getChildByName( "btn" ) as SbNavigationButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as SbNavigationButton;
		}

		override protected function onSetup():void {

			_leftButton.setLabelType( NavigationButtonLabelType.LEFT );
			_rightButton.setLabelType( NavigationButtonLabelType.RIGHT );

			_leftButton.autoCenterLabel( false );
			_leftButton.displaceLabelTf( 30, -13 );
			_leftButton.displaceLabelBg( -27, -10 );

			_rightButton.autoCenterLabel( false );
			_rightButton.displaceLabelTf( 5, -15 );
			_rightButton.displaceLabelBg( -15, -5 );

			_centerComponentsScroller = new HItemScroller();
			_centerComponentsScroller.edgeContentGap = 150;
			_centerComponentsScroller.visibleHeight = 200;
			_centerComponentsScroller.visibleWidth = 1024;
			_centerComponentsScroller.positionManager.minimumThrowingSpeed = 25;
			_centerComponentsScroller.motionStartedSignal.add( onCenterScrollerMotionStart );
			_centerComponentsScroller.motionEndedSignal.add( onCenterScrollerMotionEnd );
			addChildAt( _centerComponentsScroller, 1 );

			_leftButton.addEventListener( MouseEvent.MOUSE_UP, onButtonClicked );
			_rightButton.addEventListener( MouseEvent.MOUSE_UP, onButtonClicked );

			visible = false;
		}

		// ---------------------------------------------------------------------
		// Interface to be used by the view's mediator.
		// ---------------------------------------------------------------------

		public function hide():void {
			if( _animating ) return;
			if( !_showing ) return;
			_showing = false;
			_animating = true;
			TweenLite.to( this, 0.25, { y: BG_HEIGHT, onComplete: onHideAnimatedComplete } );
		}

		public function show():void {
			if( _animating ) return;
			if( _showing ) return;
			_showing = true;
			_animating = true;
			this.visible = true;
			TweenLite.to( this, 0.25, { y: 0, onComplete: onShowAnimatedComplete } );
		}

		public function updateSubNavigation( subNavType:Class ):void {

			if( subNavType == null ) return;

			visible = true;

			Cc.log( this, "updating sub-nav: " + subNavType );

			// Reset.
			header.visible = false;
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;
			_areButtonsSelectable = false;
			resetCenterButtons();
			_centerComponentsScroller.reset();

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
			_centerComponentsScroller.evaluateInteractionStart();
		}

		public function evaluateInteractionEnd():void {
			_centerComponentsScroller.evaluateInteractionEnd();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function resetCenterButtons():void {
			if( !_centerComponentsScroller ) return;
			_buttonPositionOffsetX = _leftButton.width / 2 + _centerComponentsScroller.edgeContentGap;
			if( _centerButtons && _centerButtons.length > 0 ) {
				var len:uint = _centerButtons.length;
				for( var i:uint; i < len; ++i ) {
					var centerButton:SbNavigationButton = _centerButtons[ i ];
					centerButton.removeEventListener( MouseEvent.MOUSE_DOWN, onButtonClicked );
					centerButton.dispose();
					centerButton = null;
				}
			}
			_centerButtons = [];
		}

		private function onButtonClicked( event:MouseEvent ):void {
			if( _centerComponentsScroller.isActive ) return; // Reject clicks while the scroller is moving.
			var button:SbNavigationButton = event.target as SbNavigationButton;
			if( !button ) button = event.target.parent as SbNavigationButton;
			trace( this, "button clicked: " + button.labelText );
			var label:String = button.labelText;
			buttonClickedCallback( label );

			if( _areButtonsSelectable && button != _leftButton && button != _rightButton ) {
				for( var i:Number = 0; i < _centerButtons.length; ++i ) {
					_centerButtons[ i ].toggleSelect( false );
				}
				button.toggleSelect( true );
			}
		}

		// ---------------------------------------------------------------------
		// Methods called by SubNavigationViewBase.
		// ---------------------------------------------------------------------

		public function addCenterButton( label:String, iconType:String, labelType:String ):Sprite {
			var specificButtonClass:Class = Class( getDefinitionByName( getQualifiedClassName( _leftButton ) ) );
			var btn:SbNavigationButton = new specificButtonClass();
			btn.labelText = label;
			btn.setIconType( iconType );
			btn.setLabelType( labelType );
			btn.x = _buttonPositionOffsetX;
			btn.y = _centerComponentsScroller.visibleHeight / 2;
			btn.addEventListener( MouseEvent.MOUSE_UP, onButtonClicked );
			if( _areButtonsSelectable ) {
				btn.isSelectable = true;
				if( _centerButtons.length == 0 ) {
					btn.toggleSelect( true );
				}
			}
			_centerComponentsScroller.addChild( btn );
			_centerButtons.push( btn );
			_buttonPositionOffsetX += 140 + BUTTON_GAP_X;
			return btn;
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
			header.width = 1.25 * header.textWidth;
			header.x = 1024 / 2 - header.width / 2;

			headerBg.width = 1.05 * header.width;
			headerBg.x = 1024 / 2 - headerBg.width / 2;
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
			// Invalidate scroller.
			_centerComponentsScroller.invalidateContent();
			// Position center buttons.
			_centerComponentsScroller.x = 1024 / 2 - _centerComponentsScroller.minWidth / 2;
			_centerComponentsScroller.y = 768 - BG_HEIGHT / 2 - _centerComponentsScroller.visibleHeight / 2;
		}

		public function areButtonsSelectable( value:Boolean ):void {
			_areButtonsSelectable = value;
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

		private function onShowAnimatedComplete():void {
			_animating = false;
			shownAnimatedSignal.dispatch();
		}

		private function onHideAnimatedComplete():void {
			this.visible = false;
			_animating = false;
			hiddenAnimatedSignal.dispatch();
		}
	}
}
