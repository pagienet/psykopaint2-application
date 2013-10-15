package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.core.managers.Stage3DProxy;

	import flash.geom.Matrix3D;

	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyGyroscopeUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;

	public class HomeViewMediator extends MediatorBase
	{
		[Inject]
		public var view : HomeView;

		[Inject]
		public var stateModel : NavigationStateModel;

		[Inject]
		public var stage3dProxy : Stage3DProxy;

		[Inject]
		public var paintingModel : PaintingModel;

		[Inject]
		public var applicationRenderer : ApplicationRenderer;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal : NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var requestHomeIntroSignal : RequestHomeIntroSignal;

		[Inject]
		public var notifyHomeViewSceneReadySignal : NotifyHomeViewSceneReadySignal;

		[Inject]
		public var notifyGyroscopeUpdateSignal : NotifyGyroscopeUpdateSignal;

		[Inject]
		public var requestBrowseGallery : RequestBrowseGallerySignal;

		// TODO: Make pop-ups truly modal using blockers instead of enforcing this on mediators!
		// probably should do the same for book, so "scrollEnabled" is not necessary at all
		[Inject]
		public var requestShowPopUpSignal : RequestShowPopUpSignal;

		[Inject]
		public var requestHidePopUpSignal : RequestHidePopUpSignal;

		private var _currentNavigationState : String;

		override public function initialize() : void
		{

			// Init.
			registerView(view);
			super.initialize();

			// Fully active states.
			manageStateChanges = false;

			// From app.
			// TODO: Reenable
//			view.zoomCompletedSignal.add( onViewZoomComplete );

			requestShowPopUpSignal.add(onShowPopUp);
			requestHidePopUpSignal.add(onHidePopUp);
			requestHomeIntroSignal.add(onIntroRequested);
			notifyGyroscopeUpdateSignal.add(onGyroscopeUpdate);

			// From view.
			view.enabledSignal.add(onEnabled);
			view.disabledSignal.add(onDisabled);

			view.activeSectionChanged.add(onActiveSectionChanged);
			view.sceneReadySignal.add(onSceneReady);
			view.stage3dProxy = stage3dProxy;

			view.enable();
		}

		private function onActiveSectionChanged(sectionID : int) : void
		{
			switch (sectionID) {
				case HomeView.GALLERY:
					requestBrowseGallery.dispatch(GalleryType.MOST_RECENT);
					requestNavigationStateChange(NavigationStateType.BOOK_GALLERY);
					break;
				case HomeView.EASEL:
					requestNavigationStateChange(NavigationStateType.HOME_ON_EASEL);
					break;
				case HomeView.HOME:
					requestNavigationStateChange(NavigationStateType.HOME);
					break;
				case HomeView.SETTINGS:
					requestNavigationStateChange(NavigationStateType.SETTINGS);
					break;
			}
		}

		override public function destroy() : void
		{

			view.disable();

			// TODO: Reenable

//			view.zoomCompletedSignal.remove( onViewZoomComplete );

			requestShowPopUpSignal.remove(onShowPopUp);
			requestHidePopUpSignal.remove(onHidePopUp);
			requestHomeIntroSignal.remove(onIntroRequested);
			view.activeSectionChanged.remove(onActiveSectionChanged);

			view.enabledSignal.remove(onEnabled);
			view.disabledSignal.remove(onDisabled);
			view.sceneReadySignal.remove(onSceneReady);
			notifyGyroscopeUpdateSignal.remove(onGyroscopeUpdate);

			view.dispose();

			super.destroy();
		}

		private function onShowPopUp(popUpType:String) : void
		{
			view.scrollingEnabled = false;
		}

		private function onHidePopUp() : void
		{
			updateScrollingForState();
		}

		private function onGyroscopeUpdate(orientationMatrix : Matrix3D) : void
		{
			view.setOrientationMatrix(orientationMatrix);
		}

		private function onEnabled() : void
		{
			GpuRenderManager.addRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL, 0);
		}

		private function onDisabled() : void
		{
			GpuRenderManager.removeRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL);
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onIntroRequested() : void
		{
			view.playIntroAnimation(onIntroComplete);
		}

		private function onIntroComplete() : void
		{
			notifyHomeViewZoomCompleteSignal.dispatch();
		}

		override protected function onStateChange(newState : String) : void
		{
			super.onStateChange(newState);

			_currentNavigationState = newState;

			switch (newState) {
				case NavigationStateType.HOME:
					view.activeSection = HomeView.HOME;
					break;
				case NavigationStateType.BOOK_GALLERY:
				case NavigationStateType.GALLERY_PAINTING:
					view.activeSection = HomeView.GALLERY;
					break;
				case NavigationStateType.HOME_ON_EASEL:
					view.activeSection = HomeView.EASEL;
					break;
				case NavigationStateType.SETTINGS:
					view.activeSection = HomeView.SETTINGS;
					break;
			}

			updateScrollingForState();
		}

		private function updateScrollingForState() : void
		{
			if (_currentNavigationState == NavigationStateType.BOOK_GALLERY)
				view.scrollingEnabled = false;
			else
				view.scrollingEnabled = true;
		}

		// From view.
		// -----------------------

		private function onSceneReady() : void
		{
			notifyHomeViewSceneReadySignal.dispatch();
		}

		private function onViewZoomComplete() : void
		{
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
