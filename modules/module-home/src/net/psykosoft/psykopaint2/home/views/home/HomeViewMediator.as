package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationCache;
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

		[Inject]
		public var notifyPaintingDataRetrievedSignal:NotifyPaintingDataRetrievedSignal;

		private var _waitingForPaintModeAfterZoomIn:Boolean;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.HOME );
			registerEnablingState( StateType.HOME_ON_EASEL );
			registerEnablingState( StateType.HOME_ON_PAINTING );
			registerEnablingState( StateType.GOING_TO_PAINT );
			registerEnablingState( StateType.SETTINGS );
			registerEnablingState( StateType.SETTINGS_WALLPAPER );
			view.stage3dProxy = stage3dProxy;

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );

			// From app.
			requestWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );
			notifyCanvasBitmapSignal.add( onCanvasSnapShot );
			requestZoomToggleSignal.add( onZoomRequested );
			notifyPaintingDataRetrievedSignal.add( onPaintingDataRetrieved );

			// From view.
			view.enabledSignal.add( onViewEnabled );
			view.setupSignal.add( onViewSetup );
			view.assetsReadySignal.add( onViewAssetsReady );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onEaselClicked():void {
			if( view.getCurrentPaintingIndex() != 1 ) return; // Ignore clicks on easel if not looking at it.
			if( view.cameraController.onMotion ) return; // Ignore clicks on easel if view is scrolling
			if( view.cameraController.zoomedIn ) return;
			_waitingForPaintModeAfterZoomIn = true;
			view.zoomIn();
		}

		private function onViewSetup():void {
			// TODO: will cause trouble if view was disposed by a memory warning and the listener is set up again...
//			view.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
//			view.cameraController.zoomCompleteSignal.add( onCameraZoomComplete );
		}

		private function onViewAssetsReady():void {
			// TODO: will cause trouble if view was disposed by a memory warning and the listener is set up again...
//			view.paintingManager.easel.clickedSignal.add( onEaselClicked );
		}

		private function onViewEnabled():void {
			// Zoom out when coming from paint state ( view zooms out, when activated, if it was zoomed in when deactivated ).
			if( view.cameraController.zoomedIn ) {
				setTimeout( function():void { // TODO: review time out - ipad seems to need it for animation to be visible when coming from the paint state
					view.zoomOut();
				}, 1000 );
			}
			// TODO: check if previously added
			view.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
			view.cameraController.zoomCompleteSignal.add( onCameraZoomComplete );
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			trace( this, "closest painting changed to index: " + paintingIndex );

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState != StateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChange( StateType.SETTINGS );
				return;
			}

			// Trigger new painting state if closest to easel ( index 1 ).
			if( stateModel.currentState != StateType.HOME_ON_EASEL && paintingIndex == 1 ) {
				requestStateChange( StateType.HOME_ON_EASEL );
				return;
			}

			// Restore home state if closest to home painting ( index 2 ).
			if( stateModel.currentState != StateType.HOME && paintingIndex == 2 ) {
				requestStateChange( StateType.HOME );
				return;
			}

			// Trigger home-painting state otherwise.
			// TODO: use proper names
			// TODO: implement painting sub-nav
			var temporaryPaintingNames:Array = [ "house on country side", "digital cowboy", "microcosmos", "patio", "jesse", "flower spots", "beautiful danger" ];
			if( paintingIndex > 2 ) {

				// TODO: delete this bit
				if( stateModel.currentState != StateType.HOME ) {
					requestStateChange( StateType.HOME );
					return;
				}

				/*if( stateModel.currentState.name != ApplicationStateType.HOME_SCREEN_ON_PAINTING ) {
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN_ON_PAINTING ) );
				}*/

//				var temporaryPaintingName:String = temporaryPaintingNames[ paintingIndex - 3 ];
//				notifyFocusedPaintingChangedSignal.dispatch( temporaryPaintingName );
			}
		}

		private var _waitingForSnapShotOfHomeView:Boolean;

		private function onCameraZoomComplete():void {

			trace( this, "zoom complete" );

			notifyZoomCompleteSignal.dispatch();

			// Clicked on easel before zoom in.
			if( _waitingForPaintModeAfterZoomIn ) {
				_waitingForPaintModeAfterZoomIn = false;
				_waitingForSnapShotOfHomeView = true;
				requestStateChange( StateType.GOING_TO_PAINT );
				var p:Point = HomeView.EASEL_FAR_ZOOM_IN;
				view.adjustCamera( p.x, p.y );
				RenderGpuCommand.snapshotScale = 1;
				RenderGpuCommand.snapshotRequested = true;
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onPaintingDataRetrieved( data:Vector.<PaintingVO> ):void {
			trace( this, "received painting data: " + data.length );
			view.createInProgressPaintings( data );
		}

		private function onCanvasSnapShot( bmd:BitmapData ):void {
			// TODO: also updates when the edge bgs are being updated from a click on NewPaintSubNav's paint button, and it shouldn't
			if( _waitingForSnapShotOfHomeView ) {
				_waitingForSnapShotOfHomeView = false;
				var p:Point = NavigationCache.isHidden ? HomeView.EASEL_FAR_ZOOM_IN : HomeView.EASEL_CLOSE_ZOOM_IN;
				view.adjustCamera( p.x, p.y );
				requestStateChange( StateType.PAINT );
			}
			else {
				view.updateEasel( bmd );
			}
		}

		private function onZoomRequested( zoomIn:Boolean ):void {
			if( !view.visible ) return;
			if( zoomIn ) view.zoomIn();
			else view.zoomOut();
		}

		private function onNavigationToggled( shown:Boolean ):void {
			view.cameraController.limitInteractionToUpperPartOfTheScreen( shown );
			if( !view.visible ) {
				var p:Point = shown ? HomeView.EASEL_FAR_ZOOM_IN : HomeView.EASEL_CLOSE_ZOOM_IN;
				view.adjustCamera( p.x, p.y );
			}
		}

		private function onGlobalGesture( gestureType:String ):void {
//			trace( this, "onGlobalGesture: " + gestureType );
			if( !view.visible ) return;
			if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN || gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN ) {
				view.cameraController.startPanInteraction();
			}
			else if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_ENDED || gestureType == GestureType.VERTICAL_PAN_GESTURE_ENDED ) {
				view.cameraController.endPanInteraction();
			}
		}

		private function onWallPaperChanged( atf:ByteArray ):void {
			if( !view.visible ) return;
			view.room.changeWallpaper( atf );
		}
	}
}
