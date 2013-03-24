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

		private var _subNavigationClasses:Dictionary;
		private var _wasShowing:Boolean;

		override public function initialize():void {

			// Stores sub navigation views.
			initSubNavigationViews();

			// View starts disabled.
			view.disable(); // TODO: all views start disabled?

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyGlobalAccelerometerSignal.add( onGlobalAcceleration );

			// From view.
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

			var subNavigationClass:Class = _subNavigationClasses[ state.name ];
			if( !subNavigationClass ) {
				throw new Error( this, "there is no sub navigation for this state: " + state.name + ". If there is, make sure to register it in initSubNavigationViews() below." );
			}

			var subNavigationInstance:SubNavigationViewBase = new subNavigationClass();

			view.enableSubNavigationView( subNavigationInstance );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewHiddenAnimated():void {
			notifyNavigationToggleSignal.dispatch( false );
		}

		private function onViewShownAnimated():void {
			notifyNavigationToggleSignal.dispatch( true );
		}

		// ---------------------------------------------------------------------
		// Internal.
		// ---------------------------------------------------------------------

		private function initSubNavigationViews():void {

			_subNavigationClasses = new Dictionary();

			// This is where application states are associated to sub-navigation views.
			_subNavigationClasses[ ApplicationStateType.HOME_SCREEN ] 					  = HomeScreenSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING ] 						  = NewPaintingSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_IMAGE ] 		  = SelectImageSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_COLORS ] 		  = ColorStyleSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_TEXTURE ] 		  = SelectTextureSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_BRUSH ] 		  = SelectBrushSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_STYLE ] 		  = SelectStyleSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_EDIT_STYLE ] 			  = EditStyleSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.SETTINGS ] 						  = SettingsSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.SETTINGS_WALLPAPER ] 			  = SelectWallpaperSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_CAPTURE_IMAGE ] 		  = CaptureImageSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_CONFIRM_CAPTURE_IMAGE ]  = ConfirmCaptureSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_CROP_IMAGE ] 			  = CropImageSubNavigationView;

		}
	}
}
