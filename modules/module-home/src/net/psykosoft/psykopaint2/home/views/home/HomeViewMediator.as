package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
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

		private var _dockedAtPaintingIndex:int = -1;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Fully active states.
			registerEnablingState( NavigationStateType.HOME );
			registerEnablingState( NavigationStateType.HOME_ON_EASEL );
			registerEnablingState( NavigationStateType.HOME_ON_FINISHED_PAINTING );
			registerEnablingState( NavigationStateType.SETTINGS );
			registerEnablingState( NavigationStateType.SETTINGS_WALLPAPER );
			registerEnablingState( NavigationStateType.HOME_PICK_SURFACE );
			registerEnablingState( NavigationStateType.PREPARE_FOR_PAINT_MODE );
			registerEnablingState( NavigationStateType.PREPARE_FOR_HOME_MODE );
			registerEnablingState( NavigationStateType.PICK_SAMPLE_IMAGE ); // TODO: delete this state

			// Frozen states.
			registerEnablingState( NavigationStateType.PICK_IMAGE );
			registerEnablingState( NavigationStateType.CAPTURE_IMAGE );
			registerEnablingState( NavigationStateType.CONFIRM_CAPTURE_IMAGE );
			registerEnablingState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE );
			//registerEnablingState( NavigationStateType.CROP );	// todo: fix so this works?
			registerEnablingState( NavigationStateType.PICK_USER_IMAGE_DESKTOP );
			registerEnablingState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS );

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

			view.dispose();

			super.destroy();
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
			view.introAnimation();
		}

		private function onEaselRectChanged():void {
			easelRectModel.rect = view.easelRect;
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

		private function onWallPaperChanged( atf:ByteArray ):void {
			if( !view.visible ) return;
			view.room.changeWallpaper( atf );
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
