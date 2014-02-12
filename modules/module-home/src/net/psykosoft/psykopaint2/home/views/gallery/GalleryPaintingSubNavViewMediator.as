package net.psykosoft.psykopaint2.home.views.gallery
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var loggedInUser : LoggedInUserProxy;

		public function GalleryPaintingSubNavViewMediator()
		{
			super();
		}

		override public function initialize() : void
		{
			view.setupSignal.addOnce(onViewSetUp);
			// Init.
			registerView(view);
			super.initialize();

			activePaintingModel.onUpdate.add(updateMenu);
		}

		private function onViewSetUp() : void
		{
			updateMenu();
		}

		override public function destroy() : void
		{
			activePaintingModel.onUpdate.remove(updateMenu);
			super.destroy();
		}

		private function updateMenu() : void
		{
			updateLoveButton();
			updateUserProfileButton();
		}

		private function updateUserProfileButton():void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;
			view.setUserProfile(painting.userName, painting.userThunbnailURL);
		}

		private function updateLoveButton() : void
		{
			var painting : GalleryImageProxy = activePaintingModel.painting;
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, !painting.isFavorited && loggedInUser.isLoggedIn() && painting.userID != loggedInUser.userID);
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
//				case GalleryBrowseSubNavView.ID_BACK:
//					goBack();
//					break;
				case GalleryPaintingSubNavView.ID_LOVE:
					lovePainting();
					break;
				case GalleryPaintingSubNavView.ID_SHARE:
					sharePainting();
					break;
				case GalleryPaintingSubNavView.PROFILE:
					// ?
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
			var painting : GalleryImageProxy = activePaintingModel.painting;
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
			galleryService.favorite(painting.id, onLovePaintingSucceeded, onLovePaintingFailed);
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
