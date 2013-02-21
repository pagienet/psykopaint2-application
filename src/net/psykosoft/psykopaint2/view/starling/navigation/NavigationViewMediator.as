package net.psykosoft.psykopaint2.view.starling.navigation
{

	import com.junkbyte.console.Cc;

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.controller.accelerometer.AccelerationType;
	import net.psykosoft.psykopaint2.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectColorsSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	/*
	* Listens to application state changes and decides which sub navigation menu to display.
	* */
	public class NavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:NavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggleSignal;

		[Inject]
		public var notifyGlobalAccelerometerSignal:NotifyGlobalAccelerometerSignal;

		private var _subNavigationCache:Dictionary;
		private var _wasShowing:Boolean;

		override public function initialize():void {

			// Stores sub navigation views.
			preCacheSections();

			// View starts disabled.
			view.disable(); // TODO: all views start disabled?

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyGlobalAccelerometerSignal.add( onGlobalAcceleration );

			// From view.
			view.backButtonTriggeredSignal.add( onViewBackButtonTriggered );
			view.shownAnimatedSignal.add( onViewShownAnimated );
			view.hiddenAnimatedSignal.add( onViewHiddenAnimated );

			// If the splash screen is not being shown,
			// it is this mediator's responsibility to trigger the home state.
			if( !Settings.SHOW_SPLASH_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
			}

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalAcceleration( type:uint ):void {
			if( type == AccelerationType.SHAKE_FORWARD ) {
				view.showAnimated();
			}
			else if( type == AccelerationType.SHAKE_BACKWARD ) {
				view.hideAnimated();
			}
		}

		private function onGlobalGesture( type:uint ):void {
			if( type == GestureType.TWO_FINGER_SWIPE_UP ) {
				view.showAnimated();
			}
			else if( type == GestureType.TWO_FINGER_SWIPE_DOWN ) {
				view.hideAnimated();
			}
			else if( type == GestureType.PINCH_GREW ) { // wall zooms on this, so we hide
				_wasShowing = view.showing;
				if( _wasShowing ) {
					view.hideAnimated();
				}
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				if( _wasShowing ) {
					view.showAnimated();
				}
			}
		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			Cc.log( this, "state changed: " + newState.name );
			if( newState.name != States.SPLASH_SCREEN ) {
				view.enable();
				evaluateSubNavigation( newState );
			}
		}

		private function evaluateSubNavigation( state:StateVO ):void {

			Cc.info( this, "enabling sub navigation: " + state.name );

			var subNavigation:SubNavigationViewBase = _subNavigationCache[ state.name ];
			if( !subNavigation ) {
				throw new Error( this, "there is no sub navigation for this state: " + state.name );
			}

			view.enableSubNavigationView( subNavigation );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewBackButtonTriggered():void {
			requestStateChangeSignal.dispatch( new StateVO( States.PREVIOUS_STATE ) );
		}

		private function onViewHiddenAnimated():void {
			notifyNavigationToggleSignal.dispatch( false );
		}

		private function onViewShownAnimated():void {
			notifyNavigationToggleSignal.dispatch( true );
		}

		// ---------------------------------------------------------------------
		// Internal.
		// ---------------------------------------------------------------------

		private function preCacheSections():void {
			_subNavigationCache = new Dictionary();

			_subNavigationCache[ States.HOME_SCREEN ] = new HomeScreenSubNavigationView();
			_subNavigationCache[ States.PAINTING_NEW ] = new NewPaintingSubNavigationView();
			_subNavigationCache[ States.PAINTING_SELECT_IMAGE ] = new SelectImageSubNavigationView();
			_subNavigationCache[ States.PAINTING_SELECT_COLORS ] = new SelectColorsSubNavigationView();
			_subNavigationCache[ States.PAINTING_SELECT_TEXTURE ] = new SelectTextureSubNavigationView();
			_subNavigationCache[ States.PAINTING_SELECT_BRUSH ] = new SelectBrushSubNavigationView();
			_subNavigationCache[ States.PAINTING_SELECT_STYLE ] = new SelectStyleSubNavigationView();
			_subNavigationCache[ States.PAINTING_EDIT_STYLE ] = new EditStyleSubNavigationView();
			_subNavigationCache[ States.SETTINGS ] = new SettingsSubNavigationView();
			_subNavigationCache[ States.SETTINGS_WALLPAPER ] = new SelectWallpaperSubNavigationView();
			_subNavigationCache[ States.PAINTING_CAPTURE_IMAGE ] = new CaptureImageSubNavigationView();
			_subNavigationCache[ States.PAINTING_CONFIRM_CAPTURE_IMAGE ] = new ConfirmCaptureSubNavigationView();

		}
	}
}
