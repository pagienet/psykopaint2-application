package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.StateModel;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.view.base.Away3dMediatorBase;

	public class HomeViewMediator extends Away3dMediatorBase
	{
		[Inject]
		public var homeView:HomeView;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggleSignal;

		override public function initialize():void {

			super.initialize();
			registerView( homeView );
			registerEnablingState( ApplicationStateType.HOME_SCREEN );
			registerEnablingState( ApplicationStateType.PAINTING );
			registerEnablingState( ApplicationStateType.SETTINGS );

			// From app.
//			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
			homeView.onEnabledSignal.add( onViewEnabled );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewEnabled():void {
			homeView.cameraController.cameraClosestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
			homeView.cameraController.motionStartedSignal.add( onViewMotionStarted );
		}

		private function onViewMotionStarted():void {
			if( stateModel.currentState.name == ApplicationStateType.SETTINGS && stateModel.previousState.name != ApplicationStateType.HOME_SCREEN ) {
				requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState.name != ApplicationStateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) );
				return;
			}

			// Trigger new painting state if closest to easel ( index 1 ).
			if( stateModel.currentState.name != ApplicationStateType.PAINTING && paintingIndex == 1 ) {
				requestStateChange( new StateVO( ApplicationStateType.PAINTING ) );
				return;
			}

			// Restore home state if closest to another painting.
			var isNotInSettings:Boolean = paintingIndex != 0 && stateModel.currentState.name.indexOf( ApplicationStateType.SETTINGS ) != -1;
			var isNotInNewPainting:Boolean = paintingIndex != 1 && stateModel.currentState.name.indexOf( ApplicationStateType.PAINTING ) != -1;
			if( isNotInSettings || isNotInNewPainting ) {
				requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( shown:Boolean ):void {
			homeView.cameraController.scrollingLimited = shown;
		}

		private function onGlobalGesture( type:uint ):void {
			return; // TODO: fix runtime error caused by the code below
			if( type == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN ) {
				homeView.cameraController.startPanInteraction();
			}
			else if( type == GestureType.HORIZONTAL_PAN_GESTURE_ENDED ) {
				homeView.cameraController.endPanInteraction();
			}
			else if( type == GestureType.PINCH_GREW ) {
				homeView.cameraController.zoomIn();
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				homeView.cameraController.zoomOut();
			}
		}

		/*private function onWallPaperChanged( image:PackagedImageVO ):void {
			trace( this, "changing wallpaper" );
			view.changeWallpaper( image.originalBmd );
		}*/

		override protected function onStateChange( newStateName:String ):void {

			// Clicking on the settings button causes animation to the settings painting.
			if( newStateName == ApplicationStateType.SETTINGS && stateModel.previousState.name == ApplicationStateType.HOME_SCREEN && homeView.cameraController.evaluateCameraCurrentClosestSnapPointIndex() != 0 ) {
				homeView.cameraController.jumpToSnapPointAnimated( 0 );
			}

			// Clicking on the back button on the settings state restores to the last snapped painting.
			if( newStateName == ApplicationStateType.HOME_SCREEN && stateModel.previousState.name == ApplicationStateType.SETTINGS ) {
				if( !homeView.cameraController.moving ) {
					homeView.cameraController.jumpToSnapPointAnimated( homeView.cameraController.previousCameraClosestSnapPointIndex );
				}
			}
		}
	}
}
