package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.LeftButton;
	import net.psykosoft.psykopaint2.core.views.components.button.RightButton;

	import org.osflash.signals.Signal;

	public class NavigationView extends ViewBase
	{
		// Declared in Flash.
		public var bg:NavigationBg;
		public var header:NavigationHeader;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;

		public var buttonClickedSignal:Signal;

		private var _leftButton:LeftButton;
		private var _rightButton:RightButton;
		private var _currentSubNavView:SubNavigationViewBase;

		private var _subNavDictionary:Dictionary;
		private var _numSubNavsBeingDisposed:int;

		private var _panel:NavigationPanel;

		public function NavigationView() {
			super();

			buttonClickedSignal = new Signal();

			_leftButton = leftBtnSide.getChildByName( "btn" ) as LeftButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as RightButton;

			initializePanel();

			setBgType( NavigationBg.BG_TYPE_ROPE );

			_subNavDictionary = new Dictionary();
		}

		override protected function onSetup():void {
			_leftButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			_rightButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Container/panel.
		// ---------------------------------------------------------------------

		private function initializePanel():void {
			_panel = new NavigationPanel();
			_panel.addChild( bg );
			_panel.addChild( leftBtnSide );
			_panel.addChild( rightBtnSide );
			addChildAt( _panel, 0 );
		}

		// ---------------------------------------------------------------------
		// Sub-navigation.
		// ---------------------------------------------------------------------

		public function updateSubNavigation( subNavType:Class ):void {

			// Keep current nav when incoming class is the abstract one.
			// TODO: review...
			if( subNavType == SubNavigationViewBase ) {
				return;
			}

			trace( this, "updating sub-nav: " + subNavType );

			// Disable old view.
			disableCurrentSubNavigation();

			// Defaults to rope bg.
			setBgType( NavigationBg.BG_TYPE_ROPE );

			// Reset.
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;

			if( !subNavType ) {
				header.setTitle( "" );
				return;
			}

			// Try to restore cached view, or create a new one.
			if( _subNavDictionary[ subNavType ] ) {
//				trace( this, "reusing cached sub navigation view" );
				_currentSubNavView = _subNavDictionary[ subNavType ];
			}
			else {
//				trace( this, "creating new sub navigation view" );
				_currentSubNavView = new subNavType();
				_currentSubNavView.setNavigation( this );
				_subNavDictionary[ subNavType ] = _currentSubNavView;
				_panel.addChildAt( _currentSubNavView, 1 );
			}
			_currentSubNavView.enable();
			_currentSubNavView.scrollerButtonClickedSignal.add( onSubNavigationScrollerButtonClicked );
		}

		public function disposeSubNavigation():void {
//			trace( this, "disposing sub-navigation views...." );
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
//				trace( "disposing sub nav: " + subNavigation );
				_panel.removeChild( subNavigation );
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

		public function getButtonIconForRightButton():Sprite {
			if( _rightButton.icon.numChildren < 2 ) return null;
			return _rightButton.icon.getChildAt( 1 ) as Sprite;
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
		// Bg.
		// ---------------------------------------------------------------------

		public function setBgType( type:String ):void {
			bg.setBgType( type );
			if( type == NavigationBg.BG_TYPE_ROPE || type == NavigationBg.BG_TYPE_WOOD_LOW ) {
				_panel.contentHeight = 140;
			}
			else {
				_panel.contentHeight = 215;
			}
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get panel():NavigationPanel {
			return _panel;
		}
	}
}
