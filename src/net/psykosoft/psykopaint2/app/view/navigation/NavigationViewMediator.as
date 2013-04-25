package net.psykosoft.psykopaint2.app.view.navigation
{

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.managers.accelerometer.AccelerationType;
	import net.psykosoft.psykopaint2.app.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.home.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.captureimage.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.editstyle.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.newpainting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.selecttexture.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;

	/*
	* Listens to application state changes and decides which sub navigation menu to display.
	* */
	public class NavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var navigationView:NavigationView;

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
		private var _anEmptySubNavigationViewHidTheNavigation:Boolean;
		private var _lastSubNavClass:Class;

		override public function initialize():void {

			super.initialize();
			registerView( navigationView );
			manageStateChanges = false;

			// Stores sub navigation views.
			initSubNavigationViews();

			// View starts disabled.
			navigationView.disable(); // TODO: all views start disabled?

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyGlobalAccelerometerSignal.add( onGlobalAcceleration );

			// From view.
			navigationView.shownAnimatedSignal.add( onViewShownAnimated );
			navigationView.hiddenAnimatedSignal.add( onViewHiddenAnimated );

			// If the splash screen is not being shown,
			// it is this mediator's responsibility to trigger the home state.
			if( !Settings.SHOW_SPLASH_SCREEN ) {
				requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalAcceleration( type:uint ):void {
			if( type == AccelerationType.SHAKE_FORWARD ) {
				navigationView.showAnimated();
			}
			else if( type == AccelerationType.SHAKE_BACKWARD ) {
				navigationView.hideAnimated();
			}
		}

		private function onGlobalGesture( type:uint ):void {
			if( type == GestureType.TWO_FINGER_SWIPE_UP ) {
				navigationView.showAnimated();
			}
			else if( type == GestureType.TWO_FINGER_SWIPE_DOWN ) {
				navigationView.hideAnimated();
			}
			else if( type == GestureType.PINCH_GREW ) { // home zooms on this, so we hide
				_wasShowing = navigationView.showing;
				if( _wasShowing ) {
					navigationView.hideAnimated();
				}
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				if( _wasShowing ) {
					navigationView.showAnimated();
				}
			}
		}

		override protected function onStateChange( newStateName:String ):void {
			if( newStateName != ApplicationStateType.SPLASH_SCREEN ) {
				navigationView.enable();
				evaluateSubNavigation( newStateName );
			}
		}

		private function evaluateSubNavigation( stateName:String ):void {

			var subNavigationClass:Class = _subNavigationClasses[ stateName ];
			if( !subNavigationClass ) {
				throw new Error( this, "there is no sub navigation for this state: " + stateName + ". If there is, make sure to register it in initSubNavigationViews() below." );
			}

			if( _lastSubNavClass == subNavigationClass ) return;

			// If we are loading an empty sub-nav view, then no need to have the bar visible.
			if( subNavigationClass == SubNavigationViewBase ) {
				_anEmptySubNavigationViewHidTheNavigation = true;
				navigationView.hideAnimated();
			}
			else if( _anEmptySubNavigationViewHidTheNavigation ) {
				_anEmptySubNavigationViewHidTheNavigation = false;
				navigationView.showAnimated();
			}

			_lastSubNavClass = subNavigationClass;
			var subNavigationInstance:SubNavigationViewBase = new subNavigationClass();

			navigationView.enableSubNavigationView( subNavigationInstance );
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
			// NOTE: If you want a state to be associated to an empty sub-navigation, associate it with the class
			// SubNavigationViewBase. This will cause the navigation view to hide.
			_subNavigationClasses[ ApplicationStateType.HOME_SCREEN ] 					  = HomeScreenSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING ] 						  = NewPaintingSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_IMAGE ] 		  = SelectImageSubNavigationView;
			_subNavigationClasses[ ApplicationStateType.PAINTING_SELECT_IMAGE_CHOOSING ]  = BackSubNavigationView;
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
			_subNavigationClasses[ ApplicationStateType.HOME_SCREEN_PAINTING ] 			  = PaintingSubNavigationView;

		}
	}
}
