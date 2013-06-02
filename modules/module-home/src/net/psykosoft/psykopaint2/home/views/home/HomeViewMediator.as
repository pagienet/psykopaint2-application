package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyNavigationToggledSignal;

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class HomeViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeView;

//		[Inject]
//		public var stateModel:StateModel;

//		[Inject]
//		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggledSignal;

//		[Inject]
//		public var notifyFocusedPaintingChangedSignal:RequestActivePaintingChangeSignal;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.STATE_HOME );
			registerEnablingState( StateType.STATE_HOME_ON_PAINTING );
			registerEnablingState( StateType.STATE_HOME_SETTINGS );
			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );

			// From app.
//			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
//			view.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

//			trace( this, "closest painting changed to index: " + paintingIndex );
/*
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
			// TODO: use proper names
			var temporaryPaintingNames:Array = [ "house on country side", "digital cowboy", "microcosmos", "patio", "jesse", "flower spots", "beautiful danger" ];
			if( paintingIndex > 2 ) {

				if( stateModel.currentState.name != ApplicationStateType.HOME_SCREEN_ON_PAINTING ) {
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN_ON_PAINTING ) );
				}

				var temporaryPaintingName:String = temporaryPaintingNames[ paintingIndex - 3 ];
				notifyFocusedPaintingChangedSignal.dispatch( temporaryPaintingName );
			}*/
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( shown:Boolean ):void {
			view.cameraController.limitInteractionToUpperPartOfTheScreen( shown );
		}

		private function onGlobalGesture( type:String ):void {
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

		private function onWallPaperChanged( bmd:BitmapData ):void {
			view.room.changeWallpaper( bmd );
		}
	}
}
