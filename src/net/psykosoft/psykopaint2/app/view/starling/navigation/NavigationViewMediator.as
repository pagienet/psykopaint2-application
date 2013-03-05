package net.psykosoft.psykopaint2.app.view.starling.navigation
{

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerationType;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalAccelerometerSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestAppStateUpdateFromCoreModuleActivationSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.HomeScreenSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.NewPaintingSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.CaptureImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.ConfirmCaptureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectImageSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.EditStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.process.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SelectWallpaperSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings.SettingsSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropImageSubNavigationView;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.SmearModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySmearModuleActivatedSignal;

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

		[Inject]
		public var requestAppStateUpdateFromCoreModuleActivationSignal:RequestAppStateUpdateFromCoreModuleActivationSignal;

		////////////////////////////////////////////////////////////////////////////////

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyPaintModuleActivatedSignal:NotifyPaintModuleActivatedSignal;

		[Inject]
		public var notifySmearModuleActivatedSignal:NotifySmearModuleActivatedSignal;

		////////////////////////////////////////////////////////////////////////////////

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var smearModule:SmearModule;

		////////////////////////////////////////////////////////////////////////////////

		private var _subNavigationCache:Dictionary;
		private var _wasShowing:Boolean;

		override public function initialize():void {

			// Stores sub navigation views.
			preCacheSections();

			// View starts disabled.
			view.disable(); // TODO: all views start disabled?

			// From core.
			// Associates drawing core module activation to application states ( listens to the core ).
			notifyCropModuleActivatedSignal.add( onCropModuleActivated );
			notifyColorStyleModuleActivatedSignal.add( onColorStyleModuleActivated );
			notifyPaintModuleActivatedSignal.add( onPaintModuleActivated );
			notifySmearModuleActivatedSignal.add( onSmearModuleActivated );

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
				requestStateChangeSignal.dispatch( new StateVO( StateType.HOME_SCREEN ) );
			}

		}

		// -----------------------
		// From core.
		// -----------------------

		// Associates module activations to application state changes.

		private function onPaintModuleActivated():void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( paintModule );
		}

		private function onColorStyleModuleActivated( image:BitmapData ):void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( colorStyleModule );
		}

		private function onCropModuleActivated( image:BitmapData ):void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( cropModule );
		}

		private function onSmearModuleActivated():void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( smearModule );
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
			if( newState.name != StateType.SPLASH_SCREEN ) {
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
			requestStateChangeSignal.dispatch( new StateVO( StateType.PREVIOUS_STATE ) );
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

			_subNavigationCache[ StateType.HOME_SCREEN ] = new HomeScreenSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_NEW ] = new NewPaintingSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_SELECT_IMAGE ] = new SelectImageSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_SELECT_COLORS ] = new ColorStyleSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_SELECT_TEXTURE ] = new SelectTextureSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_SELECT_BRUSH ] = new SelectBrushSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_SELECT_STYLE ] = new SelectStyleSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_EDIT_STYLE ] = new EditStyleSubNavigationView();
			_subNavigationCache[ StateType.SETTINGS ] = new SettingsSubNavigationView();
			_subNavigationCache[ StateType.SETTINGS_WALLPAPER ] = new SelectWallpaperSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_CAPTURE_IMAGE ] = new CaptureImageSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_CONFIRM_CAPTURE_IMAGE ] = new ConfirmCaptureSubNavigationView();
			_subNavigationCache[ StateType.PAINTING_CROP_IMAGE ] = new CropImageSubNavigationView();

		}
	}
}
