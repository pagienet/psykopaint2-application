package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbIconButton;
	import net.psykosoft.psykopaint2.core.views.components.button.SbLeftButton;
	import net.psykosoft.psykopaint2.core.views.components.button.SbRightButton;

	import org.osflash.signals.Signal;

	public class SbNavigationView extends ViewBase
	{
		// Declared in Flash.
		public var woodBg:Sprite;
		public var wire:Sprite;
		public var header:TextField;
		public var headerBg:Sprite;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;

		public var buttonClickedCallback:Function;
		public var shownSignal:Signal;
		public var showingSignal:Signal;
		public var hidingSignal:Signal;
		public var hiddenSignal:Signal;
		public var showHideUpdateSignal:Signal;

		private var _leftButton:SbLeftButton;
		private var _rightButton:SbRightButton;
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

		public function SbNavigationView() {
			super();

			shownSignal = new Signal();
			hidingSignal = new Signal();
			showingSignal = new Signal();
			hiddenSignal = new Signal();
			showHideUpdateSignal = new Signal();

			_reactiveHideStackY = new StackUtil();
			_leftButton = leftBtnSide.getChildByName( "btn" ) as SbLeftButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as SbRightButton;
			_bgHeight *= CoreSettings.GLOBAL_SCALING;
			_targetReactiveY = 768 * scaleX - _bgHeight;

			enable();

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

		public function updateSubNavigation( subNavType:Class ):void {

			if( subNavType == null ) {
				visible = false;
				return;
			}
			else {
				visible = true && !_forceHidden;
			}

			// Keep current nav when incoming class is the abstract one.
			if( subNavType == SubNavigationViewBase ) {
				return;
			}

			trace( this, "updating sub-nav: " + subNavType );

			// Reset.
			header.visible = false;
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;

			// Disable old view.
			if( _currentSubNavView ) {
				_currentSubNavView.disable();
				removeChild( _currentSubNavView );
			}

			// Hide?
			if( !subNavType ) {
				visible = false;
				return;
			}
			else if( !_hidden ) {
				visible = true && !_forceHidden;
			}

			// Create new view.
			if( _subNavDictionary[ subNavType ] ) _currentSubNavView = _subNavDictionary[ subNavType ];
			else {
				_currentSubNavView = new subNavType();
				_currentSubNavView.navigation = this;
				_subNavDictionary[ subNavType ] = _currentSubNavView;
			}
			_currentSubNavView.enable();
			addChildAt( _currentSubNavView, 2 );
		}

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

		public function toggle( time:Number = 0.5):void {
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
			TweenLite.to( this, time, { y: _bgHeight, onUpdate: onShowHideUpdate, onComplete: onHideAnimatedComplete, ease:Strong.easeOut } );
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

		public function show( time: Number = 0.5 ):void {
			trace( this, "trying to show: animating: " + _animating + ", on reactive hide: " + _onReactiveHide + ", showing: " + _showing );
			if( _animating ) return;
			if( !_onReactiveHide && _showing ) return;
			trace( this, "show" );
			_showing = true;
			_animating = true;
			showingSignal.dispatch();
			visible = true && !_forceHidden;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, time, { y: 0, onUpdate: onShowHideUpdate, onComplete: onShowAnimatedComplete, ease:Strong.easeOut } );
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
			if( _animating || _onReactiveHide || stage.mouseY < _targetReactiveY) return;
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

		public function startAutoHideMode():void
		{
			if ( !_hidden )
				addEventListener(Event.ENTER_FRAME, checkAutoHide );
		}
		
		public function stopAutoHideMode():void
		{
			removeEventListener(Event.ENTER_FRAME, checkAutoHide );
		}
		
		private function checkAutoHide( event:Event ):void
		{
			if (_hidden || _animating ) 
			{
				removeEventListener(Event.ENTER_FRAME, checkAutoHide );
			} else {
				if ( stage.mouseY > _targetReactiveY )
				{
					removeEventListener(Event.ENTER_FRAME, checkAutoHide );
					hide();
				}
			}
		}
		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		public function onButtonClicked( event:MouseEvent ):void {

			var clickedButton:NavigationButton = event.target as NavigationButton;
			if( !clickedButton ) clickedButton = event.target.parent as NavigationButton;
			if ( clickedButton )
			{
				var label:String = clickedButton.labelText;
				trace( this, "button clicked: " + clickedButton.labelText );
	
				buttonClickedCallback( label );
			} else {
				trace("##### Error - no button found");
			}
		}

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

		private function adjustHeaderTextPosition():void{
			 header.y = headerBg.y - _headerTextDefaultOffset;
		}

		private function onHeaderOutComplete():void {
			header.visible = headerBg.visible = false;
		}

		public function setLeftButton( label:String, iconType:String = ButtonIconType.BACK ):void {
			_leftButton.labelText = label;
			_leftButton.iconType = iconType;
			_leftButton.visible = true;
			leftBtnSide.visible = true;
		}

		public function setRightButton( label:String, iconType:String = ButtonIconType.CONTINUE ):void {
			_rightButton.labelText = label;
			_rightButton.iconType = iconType;
			_rightButton.visible = true;
			rightBtnSide.visible = true;
		}

		public function toggleLeftButtonVisibility( value:Boolean ):void {
			_leftButton.visible = value;
			leftBtnSide.visible = value;
		}

		public function toggleRightButtonVisibility( value:Boolean ):void {
			_rightButton.visible = value;
			rightBtnSide.visible = value;
		}
	}
}
