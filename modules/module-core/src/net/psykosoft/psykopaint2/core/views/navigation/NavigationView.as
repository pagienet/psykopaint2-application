package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.DisplayObject;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.LeftButton;
	import net.psykosoft.psykopaint2.core.views.components.button.RightButton;

	import org.osflash.signals.Signal;

	public class NavigationView extends ViewBase
	{
		// Declared in Flash.
		public var woodBg:Sprite;
		public var wire:Sprite;
		public var header:TextField;
		public var headerBg:Sprite;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;

		public var shownSignal:Signal;
		public var showingSignal:Signal;
		public var hidingSignal:Signal;
		public var hiddenSignal:Signal;
		public var showHideUpdateSignal:Signal;
		public var buttonClickedSignal:Signal;

		private var _leftButton:LeftButton;
		private var _rightButton:RightButton;
		private var _currentSubNavView:SubNavigationViewBase;

		private var _animating:Boolean;
		private var _showing:Boolean;
		private var _onReactiveHide:Boolean;
		private var _reactiveHideMouseDownY:Number;
		private var _reactiveHideStackY:StackUtil;
		private var _targetReactiveY:Number;
		private var _forceHidden:Boolean;
		private var _hidden:Boolean;
		private var _bgHeight:uint = 250;
		private var _headerDefaultY:Number;
		private var _headerTextDefaultOffset:Number;
		private var _subNavDictionary:Dictionary;
		private var _numSubNavsBeingDisposed:int;

		public function NavigationView() {
			super();

			shownSignal = new Signal();
			hidingSignal = new Signal();
			showingSignal = new Signal();
			hiddenSignal = new Signal();
			showHideUpdateSignal = new Signal();
			buttonClickedSignal = new Signal();

			_reactiveHideStackY = new StackUtil();
			_leftButton = leftBtnSide.getChildByName( "btn" ) as LeftButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as RightButton;
			_bgHeight *= CoreSettings.GLOBAL_SCALING;
			_targetReactiveY = 768 * scaleX - _bgHeight;

			// Starts hidden.
			visible = false;
			_hidden = true;
			y = _bgHeight;

			woodBg.visible = false;

			_subNavDictionary = new Dictionary();
		}

		override protected function onSetup():void {
			_leftButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			_rightButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			_headerDefaultY = headerBg.y;
			_headerTextDefaultOffset = headerBg.y - header.y;
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Sub-navigation.
		// ---------------------------------------------------------------------

		public function updateSubNavigation( subNavType:Class ):void {

			// TODO: review...
			if( subNavType == null ) {
				visible = false;
				return;
			}
			else {
				visible = true && !_forceHidden;
			}

			// Keep current nav when incoming class is the abstract one.
			// TODO: review...
			if( subNavType == SubNavigationViewBase ) {
				return;
			}

			trace( this, "updating sub-nav: " + subNavType );

			// Disable old view.
			disableCurrentSubNavigation();

			// Reset.
			header.visible = false;
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;

			// Hide?
			// TODO: review...
			if( !subNavType ) {
				visible = false;
				return;
			}
			else if( !_hidden ) {
				visible = true && !_forceHidden;
			}

			// Try to restore cached view, or create a new one.
			if( _subNavDictionary[ subNavType ] ) {

				trace( this, "reusing cached sub navigation view" );

				_currentSubNavView = _subNavDictionary[ subNavType ];
				_currentSubNavView.enable();
			}
			else {

				trace( this, "creating new sub navigation view" );

				_currentSubNavView = new subNavType();
				_currentSubNavView.setNavigation( this );
				_subNavDictionary[ subNavType ] = _currentSubNavView;
				addChildAt( _currentSubNavView, 2 );
				_currentSubNavView.enable();
			}
			_currentSubNavView.scrollerButtonClickedSignal.add( onSubNavigationScrollerButtonClicked );
		}

		public function disposeSubNavigation():void {

			trace( this, "disposing sub-navigation views...." );

			disableCurrentSubNavigation();

			var subNavigation:SubNavigationViewBase;

			// Sweep the current state of the dictionary and identify views that are to be removed.
			// It's better than sweeping the dictionary itself for item removal because it may change while stuff is being removed.
			var viewsToRemove:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for each( subNavigation in _subNavDictionary ) {
				viewsToRemove.push( subNavigation );
			}
			_subNavDictionary = new Dictionary();

			_numSubNavsBeingDisposed = viewsToRemove.length;

			for( var i:uint; i < _numSubNavsBeingDisposed; i++ ) {
				subNavigation = viewsToRemove[ i ] as SubNavigationViewBase;
				trace( "disposing sub nav: " + subNavigation );
				removeChild( subNavigation );
				// Note: removing each from display causes the disposal of the mediators, which is in charge of disposing the view itself
			}
		}

		private function disableCurrentSubNavigation():void {
			if( _currentSubNavView ) {
				_currentSubNavView.scrollerButtonClickedSignal.remove( onSubNavigationScrollerButtonClicked );
				_currentSubNavView.disable();
				_currentSubNavView = null;
			}
		}

		// ---------------------------------------------------------------------
		// Side buttons.
		// ---------------------------------------------------------------------

		public function setLeftButton( id:String, label:String, iconType:String = ButtonIconType.BACK ):void {
			_leftButton.id = id;
			_leftButton.labelText = label;
			_leftButton.iconType = iconType;
			_leftButton.visible = true;
			leftBtnSide.visible = true;
		}

		public function setRightButton( id:String, label:String, iconType:String = ButtonIconType.CONTINUE ):void {
			_rightButton.id = id;
			_rightButton.labelText = label;
			_rightButton.iconType = iconType;
			_rightButton.visible = true;
			rightBtnSide.visible = true;
		}

		public function showLeftButton( value:Boolean ):void {
			_leftButton.visible = value;
			leftBtnSide.visible = value;
		}

		public function showRightButton( value:Boolean ):void {
			_rightButton.visible = value;
			rightBtnSide.visible = value;
		}

		// ---------------------------------------------------------------------
		// Button clicks.
		// ---------------------------------------------------------------------

		// Sub-navigation scroller clicks are routed here.
		private function onSubNavigationScrollerButtonClicked( event:MouseEvent ):void {
			onButtonClicked( event );
		}

		private function onButtonClicked( event:MouseEvent ):void {

			var clickedButton:NavigationButton = ClickUtil.getObjectOfClassInHierarchy( event.target as DisplayObject, NavigationButton ) as NavigationButton;
			if( !clickedButton ) throw new Error( "unidentified button clicked." );

			trace( this, "button clicked - id: " + clickedButton.id + ", label: " + clickedButton.labelText );
			buttonClickedSignal.dispatch( clickedButton.id );
		}

		// ---------------------------------------------------------------------
		// Header.
		// ---------------------------------------------------------------------

		public function setHeader( value:String ):void {

			TweenLite.killTweensOf( headerBg );
			headerBg.y = _headerDefaultY + headerBg.height;
			adjustHeaderTextPosition();

			if( value == "" ) {
				header.visible = headerBg.visible = false;
				return;
			}
			else {
				header.visible = headerBg.visible = true;
			}

			header.text = value;

			header.height = 1.25 * header.textHeight;
			header.width = 15 + header.textWidth;
			header.x = 1024 / 2 - header.width / 2;

			headerBg.width = header.width + 50;
			headerBg.x = 1024 / 2 - headerBg.width / 2 + 5;

			animateHeaderIn();
		}

		private function animateHeaderIn():void {
			TweenLite.to( headerBg, 0.5, { y: _headerDefaultY, ease: Strong.easeOut, onUpdate: adjustHeaderTextPosition, onComplete: animateHeaderOut } );
		}

		private function animateHeaderOut():void {
			TweenLite.to( headerBg, 0.25, { delay: 2, y: _headerDefaultY + headerBg.height, ease: Strong.easeIn, onUpdate: adjustHeaderTextPosition, onComplete: onHeaderOutComplete } );
		}

		private function adjustHeaderTextPosition():void {
			header.y = headerBg.y - _headerTextDefaultOffset;
		}

		private function onHeaderOutComplete():void {
			header.visible = headerBg.visible = false;
		}

		// ---------------------------------------------------------------------
		// Show/hide.
		// ---------------------------------------------------------------------

		public function toggle( time:Number = 0.5 ):void {
			if( _showing ) hide( time );
			else show( time );
		}

		public function hide( time:Number = 0.5 ):void {
			if( _animating ) return;
			if( !_onReactiveHide && !_showing ) return;
			trace( this, "hide" );
			hidingSignal.dispatch();
			_showing = false;
			_animating = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, time, { y: _bgHeight, onUpdate: onShowHideUpdate, onComplete: onHideAnimatedComplete, ease: Strong.easeOut } );
			TweenLite.to( this, time, { y: _bgHeight, onUpdate: onShowHideUpdate, onComplete: onHideAnimatedComplete, ease: Strong.easeOut } );
		}

		private function onHideAnimatedComplete():void {
			hiddenSignal.dispatch();
			visible = false;
			_animating = false;
			_hidden = true;
			_targetReactiveY = 768 * scaleX - _bgHeight * 0.2;
			NavigationCache.isHidden = true;
		}

		public function show( time:Number = 0.5 ):void {
			trace( this, "trying to show: animating: " + _animating + ", on reactive hide: " + _onReactiveHide + ", showing: " + _showing );
			if( _animating ) return;
			if( !_onReactiveHide && _showing ) return;
			trace( this, "show" );
			_showing = true;
			_animating = true;
			showingSignal.dispatch();
			visible = true && !_forceHidden;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, time, { y: 0, onUpdate: onShowHideUpdate, onComplete: onShowAnimatedComplete, ease: Strong.easeOut } );
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

		public function evaluateReactiveHideStart():void {
			if( _animating || _onReactiveHide || stage.mouseY < _targetReactiveY ) return;
			//if( _onReactiveHide ) return;
			//if( stage.mouseY < _targetReactiveY ) return; // reject interactions outside of the navigation area
			_onReactiveHide = true;
			if( _hidden ) {
				visible = true && !_forceHidden;
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

		public function startAutoHideMode():void {
			if( !_hidden )
				addEventListener( Event.ENTER_FRAME, checkAutoHide );
		}

		public function stopAutoHideMode():void {
			removeEventListener( Event.ENTER_FRAME, checkAutoHide );
		}

		private function checkAutoHide( event:Event ):void {
			if( _hidden || _animating ) {
				removeEventListener( Event.ENTER_FRAME, checkAutoHide );
			} else {
				if( stage.mouseY > _targetReactiveY ) {
					removeEventListener( Event.ENTER_FRAME, checkAutoHide );
					hide();
				}
			}
		}

		// ---------------------------------------------------------------------
		// Event handlers.
		// ---------------------------------------------------------------------

		override protected function onAddedToStage():void {
			// TODO: remove on release
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {
			if( event.keyCode == Keyboard.H ) {
				_forceHidden = !_forceHidden;
				visible = !_forceHidden;
			}
		}
	}
}