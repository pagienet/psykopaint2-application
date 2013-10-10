package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.geom.Matrix3D;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;

	import org.gestouch.events.GestureEvent;

	public class HomeViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeView;

		[Inject]
		public var stateModel:NavigationStateModel;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var applicationRenderer:ApplicationRenderer;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal:NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var requestHomeViewScrollSignal:RequestHomeViewScrollSignal;

		[Inject]
		public var requestHomeIntroSignal:RequestHomeIntroSignal;

		[Inject]
		public var notifyHomeViewSceneReadySignal:NotifyHomeViewSceneReadySignal;

		[Inject]
		public var notifyGyroscopeUpdateSignal:NotifyGyroscopeUpdateSignal;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var requestBrowseGallery : RequestBrowseGallerySignal;

		private var _dockedAtSnapIndex:int = -1;
		private var _allowPanning:Boolean = true;
		private var _lastAllowPanningBeforeNegation:int;	// 1 = allow, -1 not allow, 0 whatever it was before last not allow-

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Fully active states.
			manageStateChanges = false;
			// NOTE: home view is no longer associated to states

			// From app.
// TODO: Reenable
//			notifyGlobalGestureSignal.add( onGlobalGesture );
//			notifyNavigationToggleSignal.add( onNavigationToggled );
//			requestHomeViewScrollSignal.add( onScrollRequested );
			requestHomeIntroSignal.add( onIntroRequested );
			notifyGyroscopeUpdateSignal.add ( onGyroscopeUpdate );
			requestHomePanningToggleSignal.add ( onTogglePanning );

			// From view.
			view.enabledSignal.add( onEnabled );
			view.disabledSignal.add( onDisabled );

//			view.closestSnapPointChangedSignal.add( onViewClosestSnapPointChanged );
//			view.zoomCompletedSignal.add( onViewZoomComplete );
			view.sceneReadySignal.add( onSceneReady );
			view.stage3dProxy = stage3dProxy;

			view.enable();
		}

		override public function destroy():void {

			view.disable();

			// TODO: Reenable
//			notifyGlobalGestureSignal.remove( onGlobalGesture );
//			notifyNavigationToggleSignal.remove( onNavigationToggled );
//			requestHomeViewScrollSignal.remove( onScrollRequested );
			requestHomeIntroSignal.remove( onIntroRequested );

			// TODO: Re-implement these properly
//			view.closestSnapPointChangedSignal.remove( onViewClosestSnapPointChanged );
//			view.zoomCompletedSignal.remove( onViewZoomComplete );

			view.enabledSignal.remove( onEnabled );
			view.disabledSignal.remove( onDisabled );
			view.sceneReadySignal.remove( onSceneReady );
			notifyGyroscopeUpdateSignal.remove ( onGyroscopeUpdate );
			requestHomePanningToggleSignal.remove ( onTogglePanning );

			view.dispose();

			super.destroy();
		}

		private function onTogglePanning( enable:int ):void {
			if( enable == -1 ) {
				_lastAllowPanningBeforeNegation = _allowPanning ? 1 : -1;
				_allowPanning = false;
			}
			else if( enable == 0 ) {
				_allowPanning = _lastAllowPanningBeforeNegation;
			}
			else {
				_allowPanning = true;
			}
		}

		private function onGyroscopeUpdate(orientationMatrix : Matrix3D) : void
		{
			view.setOrientationMatrix(orientationMatrix);
		}

		private function onEnabled() : void
		{
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL, 0 );
		}

		private function onDisabled() : void
		{
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onIntroRequested():void {
			view.playIntroAnimation();
		}

		/*private function onNavigationToggled( shown:Boolean ):void {
			if ( view.isEnabled )
				view.scrollCameraController.limitInteractionToUpperPartOfTheScreen( shown );
		}

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
			trace( this, "onGlobalGesture: " + gestureType );
			if( !view.visible || !_allowPanning ) return;
			if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN || gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN ) {
				view.scrollCameraController.startPanInteraction();
			}
			else if( gestureType == GestureType.HORIZONTAL_PAN_GESTURE_ENDED || gestureType == GestureType.VERTICAL_PAN_GESTURE_ENDED ) {
				view.scrollCameraController.endPanInteraction();
			}
		}   */

		override protected function onStateChange( newState:String ):void {

			super.onStateChange( newState );
		}

		/*private function onScrollRequested( index:int ):void {
			view.scrollCameraController.positionManager.animateToIndex( index );
		} */

		// -----------------------
		// From view.
		// -----------------------

		private function onSceneReady():void {
			notifyHomeViewSceneReadySignal.dispatch();
		}

		private function onViewZoomComplete():void {
			notifyHomeViewZoomCompleteSignal.dispatch();
		}

		/*private function onViewClosestSnapPointChanged( snapPointIndex:uint ):void {

			trace( this, "closest painting changed to index: " + snapPointIndex );
			_dockedAtSnapIndex = snapPointIndex;

			// Variable.
			var homePaintingIndex:uint = view.paintingManager.homePaintingIndex;

			// Trigger SETTINGS state if closest to settings painting ( index 0 ).
			if( stateModel.currentState != NavigationStateType.SETTINGS && snapPointIndex == 0 ) {
				requestNavigationStateChange( NavigationStateType.SETTINGS );
				return;
			}

			// Trigger NEW PAINTING state if closest to easel ( index 1 ).
			if( stateModel.currentState != NavigationStateType.HOME_ON_EASEL && snapPointIndex == 1 ) {
				requestNavigationStateChange( NavigationStateType.HOME_ON_EASEL );
				return;
			}

			// Restore HOME state if closest to home painting ( index 2 ).
			if( stateModel.currentState != NavigationStateType.HOME && snapPointIndex == homePaintingIndex ) {
				requestNavigationStateChange( NavigationStateType.HOME );
				return;
			}

			if( stateModel.currentState != NavigationStateType.BOOK_GALLERY && snapPointIndex == 3 ) {
				requestHomePanningToggleSignal.dispatch(-1);
				requestBrowseGallery.dispatch(GalleryType.MOST_RECENT);
				return;
			}
		}   */
	}
}
