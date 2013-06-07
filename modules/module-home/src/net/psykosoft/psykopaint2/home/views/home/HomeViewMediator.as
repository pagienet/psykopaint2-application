package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	public class HomeViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeView;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggledSignal;

//		[Inject]
//		public var notifyFocusedPaintingChangedSignal:RequestActivePaintingChangeSignal;

		[Inject]
		public var notifyCanvasBitmapSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var notifyZoomCompleteSignal:NotifyZoomCompleteSignal;

		[Inject]
		public var requestZoomToggleSignal:RequestZoomToggleSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.STATE_HOME );
			registerEnablingState( StateType.STATE_HOME_ON_EASEL );
			registerEnablingState( StateType.STATE_HOME_ON_PAINTING );
			registerEnablingState( StateType.STATE_SETTINGS );
			registerEnablingState( StateType.STATE_SETTINGS_WALLPAPER );
			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );

			// From app.
			requestWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );
			notifyCanvasBitmapSignal.add( onCanvasBitmapReceived );
			requestZoomToggleSignal.add( onZoomRequested );

			// From view.
			view.enabledSignal.add( onViewEnabled );
			view.setupSignal.add( onViewSetup );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewSetup():void {
			// TODO: will cause trouble if view was disposed by a memory warning and the listener is set up again...
			view.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
			view.cameraController.zoomCompleteSignal.add( onCameraZoomComplete );
		}

		private function onViewEnabled():void {
			// Zoom out when coming from paint state ( view zooms out, when activated, if it was zoomed in when deactivated ).
			if( view.cameraController.zoomedIn ) {
				setTimeout( function():void { // TODO: review time out - ipad seems to need it for animation to be visible when coming from the paint state
					view.zoomOut();
				}, 1000 );
			}
		}

		private function onCameraZoomComplete():void {
			notifyZoomCompleteSignal.dispatch();
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			trace( this, "closest painting changed to index: " + paintingIndex );

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState != StateType.STATE_SETTINGS && paintingIndex == 0 ) {
				requestStateChange( StateType.STATE_SETTINGS );
				return;
			}

			// Trigger new painting state if closest to easel ( index 1 ).
			if( stateModel.currentState != StateType.STATE_HOME_ON_EASEL && paintingIndex == 1 ) {
				requestStateChange( StateType.STATE_HOME_ON_EASEL );
				return;
			}

			// Restore home state if closest to home painting ( index 2 ).
			if( stateModel.currentState != StateType.STATE_HOME && paintingIndex == 2 ) {
				requestStateChange( StateType.STATE_HOME );
				return;
			}

			// Trigger home-painting state otherwise.
			// TODO: use proper names
			// TODO: implement painting sub-nav
			var temporaryPaintingNames:Array = [ "house on country side", "digital cowboy", "microcosmos", "patio", "jesse", "flower spots", "beautiful danger" ];
			if( paintingIndex > 2 ) {

				// TODO: delete this bit
				if( stateModel.currentState != StateType.STATE_HOME ) {
					requestStateChange( StateType.STATE_HOME );
					return;
				}

				/*if( stateModel.currentState.name != ApplicationStateType.HOME_SCREEN_ON_PAINTING ) {
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN_ON_PAINTING ) );
				}*/

//				var temporaryPaintingName:String = temporaryPaintingNames[ paintingIndex - 3 ];
//				notifyFocusedPaintingChangedSignal.dispatch( temporaryPaintingName );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onZoomRequested( zoomIn:Boolean ):void {
			if( !view.visible ) return;
			if( zoomIn ) view.zoomIn();
			else view.zoomOut();
		}

		private function onCanvasBitmapReceived( bmd:BitmapData ):void {
			trace( this, "retrieved canvas bitmap: " + bmd );
//			view.addChild( new Bitmap( bmd ) );
			view.updateEasel( bmd );
			// TODO: cant we just pass the back buffer texture from canvas model to the easel's material? why do we need a bitmap?
		}

		private function onNavigationToggled( shown:Boolean ):void {
			if( !view.visible ) return;
			view.cameraController.limitInteractionToUpperPartOfTheScreen( shown );
		}

		private function onGlobalGesture( type:String ):void {
			if( !view.visible ) return;
			if( type == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN ) {
				view.cameraController.startPanInteraction();
			}
			else if( type == GestureType.HORIZONTAL_PAN_GESTURE_ENDED ) {
				view.cameraController.endPanInteraction();
			}
			else if( type == GestureType.PINCH_GREW ) {
				view.zoomIn();
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				view.zoomOut();
			}
		}

		private function onWallPaperChanged( atf:ByteArray ):void {
			if( !view.visible ) return;
			view.room.changeWallpaper( atf );
		}
	}
}
