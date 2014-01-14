package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestUpdateGalleryPaintingMenuSignal;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var requestUpdateGalleryPaintingMenuSignal : RequestUpdateGalleryPaintingMenuSignal;

		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		private var _activePainting : GalleryImageProxy;


		public function GalleryPaintingSubNavViewMediator()
		{
			super();
		}

		override public function initialize() : void
		{
			// Init.
			registerView(view);
			super.initialize();

			requestUpdateGalleryPaintingMenuSignal.add(onRequestUpdateGalleryPaintingMenu);
		}

		override public function destroy() : void
		{
			requestUpdateGalleryPaintingMenuSignal.remove(onRequestUpdateGalleryPaintingMenu);
			super.destroy();
		}

		private function onRequestUpdateGalleryPaintingMenu(painting : GalleryImageProxy) : void
		{
			_activePainting = painting;
			updateLoveButton();
		}

		private function updateLoveButton() : void
		{
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, !_activePainting.isFavorited && loggedInUser.isLoggedIn() && _activePainting.userID != loggedInUser.userID);
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
				case GalleryBrowseSubNavView.ID_BACK:
					goBack();
					break;
				case GalleryPaintingSubNavView.ID_LOVE:
					lovePainting();
					break;
				case GalleryPaintingSubNavView.ID_SHARE:
					sharePainting();
					break;
			}
		}

		private function sharePainting() : void
		{
			requestNavigationStateChange(NavigationStateType.GALLERY_SHARE);
		}

		private function goBack() : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.HOME_ON_EASEL);
		}

		private function lovePainting() : void
		{
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
			galleryService.favorite(_activePainting.id, onLovePaintingSucceeded, onLovePaintingFailed);
		}

		private function onLovePaintingSucceeded() : void
		{
			// put here just in case we want to give feedback in the button
		}

		private function onLovePaintingFailed(amfErrorCode : uint) : void
		{
			// TODO: Display whoops message

			// do not simply set to true, you never know...
			updateLoveButton();
		}
	}
}
