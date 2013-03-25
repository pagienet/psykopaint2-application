package net.psykosoft.psykopaint2.app.view.home
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.StateModel;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class HomeViewMediator extends Mediator
	{
		[Inject]
		public var view:HomeView;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggleSignal;

		private var _firstLoad:Boolean = true;
		private var _lastClosestSnapPoint:uint = 1;

		override public function initialize():void {

			Cc.log( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
//			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
			view.closestPaintingChangedSignal.add( onViewClosestPaintingChanged );
			view.motionStartedSignal.add( onViewMotionStarted );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewMotionStarted():void {
			if( stateModel.currentState.name == ApplicationStateType.SETTINGS && stateModel.previousState.name != ApplicationStateType.HOME_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			// Remember last snapped painting.
			if( paintingIndex > 1 ) _lastClosestSnapPoint = paintingIndex;

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState.name != ApplicationStateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.SETTINGS ) );
				return;
			}

			// Trigger new painting state if closest to easel ( index 1 ).
			if( stateModel.currentState.name != ApplicationStateType.PAINTING && paintingIndex == 1 ) {
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PAINTING ) );
				return;
			}

			// Restore home state if closest to another painting.
			var isNotInSettings:Boolean = paintingIndex != 0 && stateModel.currentState.name.indexOf( ApplicationStateType.SETTINGS ) != -1;
			var isNotInNewPainting:Boolean = paintingIndex != 1 && stateModel.currentState.name.indexOf( ApplicationStateType.PAINTING ) != -1;
			if( isNotInSettings || isNotInNewPainting ) {
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( shown:Boolean ):void {
			view.limitScrolling = shown;
		}

		private function onGlobalGesture( type:uint ):void {
			if( type == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN ) {
				view.startPanInteraction();
			}
			else if( type == GestureType.HORIZONTAL_PAN_GESTURE_ENDED ) {
				view.stopPanInteraction();
			}
			else if( type == GestureType.PINCH_GREW ) {
				view.zoomIn();
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				view.zoomOut();
			}
		}

		/*private function onWallPaperChanged( image:PackagedImageVO ):void {
			trace( this, "changing wallpaper" );
			view.changeWallpaper( image.originalBmd );
		}*/

		private function onApplicationStateChanged( newState:StateVO ):void {

			// Clicking on the settings button causes animation to the settings painting.
			if( newState.name == ApplicationStateType.SETTINGS && stateModel.previousState.name == ApplicationStateType.HOME_SCREEN && view.currentPainting != 0 ) {
				view.animateToPainting( 0 );
				return;
			}

			// Clicking on the back button on the settings state restores to the last snapped painting.
			if( newState.name == ApplicationStateType.HOME_SCREEN && stateModel.previousState.name == ApplicationStateType.SETTINGS ) {
				if( !view.cameraAwake ) {
					view.animateToPainting( _lastClosestSnapPoint );
				}
				return;
			}

			// When is the view visible?
			var viewIsVisible:Boolean = false;
			if( newState.name == ApplicationStateType.HOME_SCREEN ) viewIsVisible = true;
			if( newState.name == ApplicationStateType.PAINTING ) viewIsVisible = true;
			if( newState.name.indexOf( ApplicationStateType.SETTINGS ) != -1 ) viewIsVisible = true;
			// More states could cause the view to show...
			if( viewIsVisible ) {
				if( _firstLoad ) {
					view.loadDefaultHomeFrames();
					view.loadUserFrames();
					_firstLoad = false;
				}
				view.enable();
			}
			else {
				view.disable();
			}

		}
	}
}
