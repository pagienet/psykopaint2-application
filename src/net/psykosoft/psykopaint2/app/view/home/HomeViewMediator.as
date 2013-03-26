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

		override public function initialize():void {

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
//			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
			view.onEnabledSignal.add( onViewEnabled );
			view.onDisabledSignal.add( onViewDisabled );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewEnabled():void {
			view.cameraController.cameraClosestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
			view.cameraController.motionStartedSignal.add( onViewMotionStarted );
		}

		private function onViewDisabled():void {
			view.cameraController.cameraClosestSnapPointChangedSignal.remove( onViewClosestPaintingChanged );
			view.cameraController.motionStartedSignal.remove( onViewMotionStarted );
		}

		private function onViewMotionStarted():void {
			if( stateModel.currentState.name == ApplicationStateType.SETTINGS && stateModel.previousState.name != ApplicationStateType.HOME_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

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
			view.cameraController.scrollingLimited = shown;
		}

		private function onGlobalGesture( type:uint ):void {
			if( type == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN ) {
				view.cameraController.startPanInteraction();
			}
			else if( type == GestureType.HORIZONTAL_PAN_GESTURE_ENDED ) {
				view.cameraController.endPanInteraction();
			}
			else if( type == GestureType.PINCH_GREW ) {
				view.cameraController.zoomIn();
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				view.cameraController.zoomOut();
			}
		}

		/*private function onWallPaperChanged( image:PackagedImageVO ):void {
			trace( this, "changing wallpaper" );
			view.changeWallpaper( image.originalBmd );
		}*/

		private function onApplicationStateChanged( newState:StateVO ):void {

			// Clicking on the settings button causes animation to the settings painting.
			if( newState.name == ApplicationStateType.SETTINGS && stateModel.previousState.name == ApplicationStateType.HOME_SCREEN && view.cameraController.evaluateCameraCurrentClosestSnapPointIndex() != 0 ) {
				view.cameraController.jumpToSnapPointAnimated( 0 );
				return;
			}

			// Clicking on the back button on the settings state restores to the last snapped painting.
			if( newState.name == ApplicationStateType.HOME_SCREEN && stateModel.previousState.name == ApplicationStateType.SETTINGS ) {
				if( !view.cameraController.moving ) {
					view.cameraController.jumpToSnapPointAnimated( view.cameraController.previousCameraClosestSnapPointIndex );
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
				view.enable();
			}
			else {
				view.disable();
			}

		}
	}
}
