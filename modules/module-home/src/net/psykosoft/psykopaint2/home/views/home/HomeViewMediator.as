package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.model.WallpaperModel;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	import org.gestouch.events.GestureEvent;

	public class HomeViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeView;

		[Inject]
		public var stateModel:NavigationStateModel;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var notifyPaintingDataRetrievedSignal:NotifyPaintingDataSetSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var applicationRenderer:ApplicationRenderer;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal:NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var requestHomeViewScrollSignal:RequestHomeViewScrollSignal;

		[Inject]
		public var requestHomeIntroSignal:RequestHomeIntroSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var wallpaperModel:WallpaperModel;

		[Inject]
		public var notifyHomeViewSceneReadySignal:NotifyHomeViewSceneReadySignal;

		private var _dockedAtPaintingIndex:int = -1;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Fully active states.
			manageStateChanges = false;
			// NOTE: home view is no longer associated to states

			// From app.
			requestWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );
			notifyPaintingDataRetrievedSignal.add( onPaintingDataRetrieved );
			requestEaselPaintingUpdateSignal.add( onEaselUpdateRequest );
			requestHomeViewScrollSignal.add( onScrollRequested );
			requestHomeIntroSignal.add( onIntroRequested );

			// From view.
			view.closestPaintingChangedSignal.add( onViewClosestPaintingChanged );
			view.zoomCompletedSignal.add( onViewZoomComplete );
			view.easelRectChanged.add( onEaselRectChanged );
			view.enabledSignal.add( onEnabled );
			view.disabledSignal.add( onDisabled );
			view.sceneReadySignal.add( onSceneReady );

			view.stage3dProxy = stage3dProxy;

			view.enable();
		}

		override public function destroy():void {

			view.disable();

			requestWallpaperChangeSignal.remove( onWallPaperChanged );
			notifyGlobalGestureSignal.remove( onGlobalGesture );
			notifyNavigationToggleSignal.remove( onNavigationToggled );
			notifyPaintingDataRetrievedSignal.remove( onPaintingDataRetrieved );
			requestEaselPaintingUpdateSignal.remove( onEaselUpdateRequest );
			requestHomeViewScrollSignal.remove( onScrollRequested );
			requestHomeIntroSignal.remove( onIntroRequested );
			view.closestPaintingChangedSignal.remove( onViewClosestPaintingChanged );
			view.zoomCompletedSignal.remove( onViewZoomComplete );
			view.easelRectChanged.remove( onEaselRectChanged );
			view.enabledSignal.remove( onEnabled );
			view.disabledSignal.remove( onDisabled );
			view.sceneReadySignal.remove( onSceneReady );

			view.dispose();

			super.destroy();
		}

		private function onEnabled() : void
		{
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL, 0 );
			changeWallpaperFromId( wallpaperModel.wallpaperId );
		}

		private function onDisabled() : void
		{
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onIntroRequested():void {
			view.introAnimation();
		}

		private function onEaselRectChanged():void {
			easelRectModel.localScreenRect = view.easelRect;
		}

		private function onEaselUpdateRequest( paintingVO:PaintingInfoVO, animateIn:Boolean, disposeWhenDone:Boolean ):void {
			view.paintingManager.easel.setContent( paintingVO, animateIn, disposeWhenDone );
		}

		private function onPaintingDataRetrieved( data:Vector.<PaintingInfoVO> ):void {
			if( data.length == 0 ) return;
			var latestVo:PaintingInfoVO = data[ 0 ];
			view.paintingManager.easel.setContent( latestVo );
		}

		private function onNavigationToggled( shown:Boolean ):void {
			if ( view.isEnabled )
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

		private function onWallPaperChanged( id:String ):void {
			if( !view.visible ) return;
			changeWallpaperFromId( id );
		}

		private function changeWallpaperFromId( id:String ):void {
			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";
			var url:String = rootUrl + "away3d/wallpapers/fullsize/" + id + extra + ".atf";
			view.room.changeWallpaper( url );
		}

		override protected function onStateChange( newState:String ):void {

			super.onStateChange( newState );
		}

		private function onScrollRequested( index:int ):void {
			view.scrollCameraController.positionManager.animateToIndex( index );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSceneReady():void {
			notifyHomeViewSceneReadySignal.dispatch();
		}

		private function onViewZoomComplete():void {
			notifyHomeViewZoomCompleteSignal.dispatch();
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			trace( this, "closest painting changed to index: " + paintingIndex );
			_dockedAtPaintingIndex = paintingIndex;

			// Variable.
			var homePaintingIndex:uint = view.paintingManager.homePaintingIndex;

			// Trigger SETTINGS state if closest to settings painting ( index 0 ).
			if( stateModel.currentState != NavigationStateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChange__OLD_TO_REMOVE( NavigationStateType.SETTINGS );
				return;
			}

			// Trigger NEW PAINTING state if closest to easel ( index 1 ).
			if( stateModel.currentState != NavigationStateType.HOME_ON_EASEL && paintingIndex == 1 ) {
				requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME_ON_EASEL );
				return;
			}

			// Restore HOME state if closest to home painting ( index 2 ).
			if( stateModel.currentState != NavigationStateType.HOME && paintingIndex == homePaintingIndex ) {
				requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME );
				return;
			}

			// Trigger home-painting state otherwise.
			// TODO: use proper names
			// TODO: implement painting sub-nav
			var temporaryPaintingNames:Array = [ "house on country side", "digital cowboy", "microcosmos", "patio", "jesse", "flower spots", "beautiful danger" ];
			if( paintingIndex > homePaintingIndex ) {

				// TODO: delete this bit
				if( stateModel.currentState != NavigationStateType.HOME ) {
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME );
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
