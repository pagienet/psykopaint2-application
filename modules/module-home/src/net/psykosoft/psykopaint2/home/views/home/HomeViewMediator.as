package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.SnapshotPromise;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataRetrievedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	import org.gestouch.events.GestureEvent;

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

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var notifyPaintingDataRetrievedSignal:NotifyPaintingDataRetrievedSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestEaselRectInfoSignal:RequestEaselRectInfoSignal;

		[Inject]
		public var notifyEaselRectInfoSignal:NotifyEaselRectInfoSignal;

		[Inject]
		public var requestSetCanvasBackgroundSignal:RequestSetCanvasBackgroundSignal;

		[Inject]
		public var applicationRenderer:ApplicationRenderer;

		private var _waitingForFreezeSnapshot:Boolean;
		private var _freezingStates:Vector.<String>;
		private var _dockedAtPaintingIndex:int = -1;

		private var _snapshotPromise:SnapshotPromise;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			_freezingStates = new Vector.<String>();
			view.stage3dProxy = stage3dProxy;

			// Fully active states.
			registerEnablingState( StateType.HOME );
			registerEnablingState( StateType.HOME_ON_EASEL );
			registerEnablingState( StateType.HOME_ON_FINISHED_PAINTING );
			registerEnablingState( StateType.SETTINGS );
			registerEnablingState( StateType.SETTINGS_WALLPAPER );
			registerEnablingState( StateType.HOME_PICK_SURFACE );
			registerEnablingState( StateType.PREPARE_FOR_PAINT_MODE );
			registerEnablingState( StateType.PICK_SAMPLE_IMAGE ); // TODO: delete this state

			// Frozen states.
			registerFreezingState( StateType.PICK_IMAGE );
			registerFreezingState( StateType.CAPTURE_IMAGE );
			registerFreezingState( StateType.CONFIRM_CAPTURE_IMAGE );
			registerFreezingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
			registerFreezingState( StateType.BOOK_PICK_USER_IMAGE_IOS );
			registerFreezingState( StateType.CROP );
			registerFreezingState( StateType.PICK_USER_IMAGE_DESKTOP );

			// Register view gpu rendering in core.
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL, 0 );

			// From app.
			requestWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );
			notifyPaintingDataRetrievedSignal.add( onPaintingDataRetrieved );
			requestEaselPaintingUpdateSignal.add( onEaselUpdateRequest );
			requestEaselRectInfoSignal.add( onEaselRectInfoRequested );

			// From view.
			view.setupSignal.add( onViewSetup );
			view.assetsReadySignal.add( onViewAssetsReady );
			view.scrollCameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
		}

		private function registerFreezingState( stateName:String ):void {
			_freezingStates.push( stateName );
			registerEnablingState( stateName );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onEaselRectInfoRequested():void {
			notifyEaselRectInfoSignal.dispatch( view.easelRect );
		}

		private function onEaselUpdateRequest( paintingVO:PaintingInfoVO ):void {
			view.setEaselContent( paintingVO );
		}

		private function onPaintingDataRetrieved( data:Vector.<PaintingInfoVO> ):void {
			if( data.length == 0 ) return;

			data.sort( paintingModel.sortOnLastSaved );
			var latestVo:PaintingInfoVO = data[ 0 ];
			var len:uint = data.length;
			var vo:PaintingInfoVO;

			view.paintingManager.setEaselContent( latestVo );
		}

		private function onNavigationToggled( shown:Boolean ):void {
			view.scrollCameraController.limitInteractionToUpperPartOfTheScreen( shown );
			// TODO: will the navigation be hide-able in home?
			/*if( !view.visible ) {
			 var p:Point = shown ? HomeView.EASEL_FAR_ZOOM_IN : HomeView.EASEL_CLOSE_ZOOM_IN;
			 view.adjustCamera( p.x, p.y );
			 }*/
		}

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
//			trace( this, "onGlobalGesture: " + gestureType );
			if( !view.visible ) return;
			if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN || gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN ) {
				view.scrollCameraController.startPanInteraction();
			}
			else if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_ENDED || gestureType == GestureType.VERTICAL_PAN_GESTURE_ENDED ) {
				view.scrollCameraController.endPanInteraction();
			}
		}

		private function onWallPaperChanged( atf:ByteArray ):void {
			if( !view.visible ) return;
			view.room.changeWallpaper( atf );
		}


		override protected function onStateChange( newState:String ):void {
			if( _freezingStates.indexOf( newState ) != -1 ) freezeView();
			else {
				view.unFreeze();

				if( newState == StateType.PREPARE_FOR_PAINT_MODE ) {

					// Looking at easel?
					if( _dockedAtPaintingIndex != 1 ) {
						throw new Error( "HomeViewMediator - requested to transition to paint and not at easel." );
					}

					_snapshotPromise = applicationRenderer.requestSnapshot();
					_snapshotPromise.addEventListener( SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot );
				}

				super.onStateChange( newState );
			}
		}

		private function freezeView():void {
			trace( this, "freezing..." );
			// TODO: freeze is all black
			if( _waitingForFreezeSnapshot ) return;
			if( view.isEnabled ) {
				if( !view.frozen ) {
					_waitingForFreezeSnapshot = true;
					_snapshotPromise = applicationRenderer.requestSnapshot();
					_snapshotPromise.addEventListener( SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot );
				}
			}
			else throw new Error( "HomeViewMediator - freeze requested while the view is not active." ); // TODO: ability to freeze while view is inactive might be needed
		}

		private function onCanvasSnapShot( event:Event ):void {

			_snapshotPromise.removeEventListener( SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot );

			if( _waitingForFreezeSnapshot ) {

				trace( this, "applying freeze snapshot..." );
				view.freeze( _snapshotPromise.texture.newReference() );
				_snapshotPromise.texture.dispose();

				_waitingForFreezeSnapshot = false;
			}

			// Transition freeze?
			if( stateModel.currentState == StateType.PREPARE_FOR_PAINT_MODE ) {
				notifyEaselRectInfoSignal.dispatch( view.easelRect );
				requestSetCanvasBackgroundSignal.dispatch(_snapshotPromise.texture.newReference());
				setTimeout( function():void {
					requestStateChange( StateType.PAINT );
				}, 50 );
			}

			_snapshotPromise = null;
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewSetup():void {
			// TODO: will cause trouble if view was disposed by a memory warning and the listener is set up again...
//			view.cameraController.closestSnapPointChangedSignal.add( onViewClosestPaintingChanged );
//			view.cameraController.zoomCompleteSignal.add( onCameraZoomComplete );
		}

		private function onViewAssetsReady():void {
			// TODO: will cause trouble if view was disposed by a memory warning and the listener is set up again...
//			view.paintingManager.easel.clickedSignal.add( onEaselClicked );
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			trace( this, "closest painting changed to index: " + paintingIndex );
			_dockedAtPaintingIndex = paintingIndex;

			// Variable.
			var homePaintingIndex:uint = view.paintingManager.homePaintingIndex;

			// Trigger SETTINGS state if closest to settings painting ( index 0 ).
			if( stateModel.currentState != StateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChange( StateType.SETTINGS );
				return;
			}

			// Trigger NEW PAINTING state if closest to easel ( index 1 ).
			if( stateModel.currentState != StateType.HOME_ON_EASEL && paintingIndex == 1 ) {
				requestStateChange( StateType.HOME_ON_EASEL );
				return;
			}

			// Restore HOME state if closest to home painting ( index 2 ).
			if( stateModel.currentState != StateType.HOME && paintingIndex == homePaintingIndex ) {
				requestStateChange( StateType.HOME );
				return;
			}

			// Trigger home-painting state otherwise.
			// TODO: use proper names
			// TODO: implement painting sub-nav
			var temporaryPaintingNames:Array = [ "house on country side", "digital cowboy", "microcosmos", "patio", "jesse", "flower spots", "beautiful danger" ];
			if( paintingIndex > homePaintingIndex ) {

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
	}
}
