package net.psykosoft.psykopaint2.app.view.home
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.model.StateModel;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyFocusedPaintingChangedSignal;
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

		[Inject]
		public var notifyFocusedPaintingChangedSignal:NotifyFocusedPaintingChangedSignal;

		override public function initialize():void {

			super.initialize();
			registerView( homeView );
			registerEnablingState( ApplicationStateType.HOME_SCREEN );
			registerEnablingState( ApplicationStateType.HOME_SCREEN_PAINTING );
			registerEnablingState( ApplicationStateType.PAINTING );
			registerEnablingState( ApplicationStateType.SETTINGS );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_IMAGE );
			registerEnablingState( ApplicationStateType.SETTINGS_WALLPAPER );

			// From app.
			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
			homeView.onEnabledSignal.add( onViewEnabled );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewEnabled():void {
			homeView.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

//			trace( this, "closest painting changed to index: " + paintingIndex );

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

			// Restore home state if closest to home painting ( index 2 ).
			if( stateModel.currentState.name != ApplicationStateType.HOME_SCREEN && paintingIndex == 2 ) {
				requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN ) );
				return;
			}

			// Trigger home-painting state otherwise.
			if( paintingIndex > 2 ) {

				if( stateModel.currentState.name != ApplicationStateType.HOME_SCREEN_PAINTING ) {
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN_PAINTING ) );
				}

				var temporaryPaintingName:String = "myPainting_" + String( paintingIndex - 2 ); // TODO: use real data
				notifyFocusedPaintingChangedSignal.dispatch( temporaryPaintingName );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( shown:Boolean ):void {
			homeView.cameraController.limitInteractionToUpperPartOfTheScreen( shown );
		}

		private function onGlobalGesture( type:uint ):void {
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

		private function onWallPaperChanged( bmd:BitmapData ):void {
			homeView.room.changeWallpaper( bmd );
		}
	}
}
