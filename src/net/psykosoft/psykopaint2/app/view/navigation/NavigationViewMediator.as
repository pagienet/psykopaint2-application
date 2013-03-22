package net.psykosoft.psykopaint2.app.view.navigation
{

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerationType;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.home.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.editstyle.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.newpainting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.selecttexture.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;

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

		[Inject]
		public var notifyColorStylePresetsAvailableSignal:NotifyColorStylePresetsAvailableSignal;

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
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
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
			else if( type == GestureType.PINCH_GREW ) { // home zooms on this, so we hide
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
			if( newState.name != ApplicationStateType.SPLASH_SCREEN ) {
				view.enable();
				evaluateSubNavigation( newState );
			}
		}

		private function evaluateSubNavigation( state:StateVO ):void {

			var subNavigation:SubNavigationViewBase = _subNavigationCache[ state.name ];
			if( !subNavigation ) {
				throw new Error( this, "there is no sub navigation for this state: " + state.name + ". If there is, make sure to register it in preCacheSections() below." );
			}

			view.enableSubNavigationView( subNavigation );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewBackButtonTriggered():void {
			requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PREVIOUS_STATE ) );
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

			_subNavigationCache[ ApplicationStateType.HOME_SCREEN ] = new HomeScreenSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING ] = new NewPaintingSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_SELECT_IMAGE ] = new SelectImageSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_SELECT_COLORS ] = new ColorStyleSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_SELECT_TEXTURE ] = new SelectTextureSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_SELECT_BRUSH ] = new SelectBrushSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_SELECT_STYLE ] = new SelectStyleSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_EDIT_STYLE ] = new EditStyleSubNavigationView();
			_subNavigationCache[ ApplicationStateType.SETTINGS ] = new SettingsSubNavigationView();
			_subNavigationCache[ ApplicationStateType.SETTINGS_WALLPAPER ] = new SelectWallpaperSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_CAPTURE_IMAGE ] = new CaptureImageSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_CONFIRM_CAPTURE_IMAGE ] = new ConfirmCaptureSubNavigationView();
			_subNavigationCache[ ApplicationStateType.PAINTING_CROP_IMAGE ] = new CropImageSubNavigationView();

		}
	}
}
