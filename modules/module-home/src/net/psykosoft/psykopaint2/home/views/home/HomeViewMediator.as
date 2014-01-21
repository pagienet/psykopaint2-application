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
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewIntroZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewSceneReadySignal;
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
		public var notifyHomeViewIntroZoomComplete : NotifyHomeViewIntroZoomCompleteSignal;

		[Inject]
		public var requestHomeIntroSignal : RequestHomeIntroSignal;

		[Inject]
		public var notifyHomeViewSceneReadySignal : NotifyHomeViewSceneReadySignal;

		[Inject]
		public var notifyGyroscopeUpdateSignal : NotifyGyroscopeUpdateSignal;

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

			requestShowPopUpSignal.add(onShowPopUp);
			requestHidePopUpSignal.add(onHidePopUp);
			requestHomeIntroSignal.add(onIntroRequested);
			notifyGyroscopeUpdateSignal.add(onGyroscopeUpdate);

			// From view.
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
					requestNavigationStateChange(NavigationStateType.GALLERY_BROWSE_MOST_RECENT);
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

			requestShowPopUpSignal.remove(onShowPopUp);
			requestHidePopUpSignal.remove(onHidePopUp);
			requestHomeIntroSignal.remove(onIntroRequested);
			view.activeSectionChanged.remove(onActiveSectionChanged);

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

		private function onDisabled() : void
		{
			GpuRenderManager.removeRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL);
			_currentNavigationState = null;
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
			notifyHomeViewIntroZoomComplete.dispatch();
		}

		override protected function onStateChange(newState : String) : void
		{
			super.onStateChange(newState);

			// rendering should not happen until we're in an actual state
			if (!_currentNavigationState)
				GpuRenderManager.addRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL, 0);

			_currentNavigationState = newState;

			// this is not ideal, but hey!

			switch (newState) {
				case NavigationStateType.HOME:
					view.activeSection = HomeView.HOME;
					break;
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
				case NavigationStateType.GALLERY_BROWSE_YOURS:
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
			if (_currentNavigationState == NavigationStateType.GALLERY_SHARE ||
				_currentNavigationState == NavigationStateType.CAPTURE_IMAGE ||
				_currentNavigationState == NavigationStateType.PICK_USER_IMAGE_IOS ||
				_currentNavigationState == NavigationStateType.PICK_USER_IMAGE_DESKTOP )
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
	}
}