package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLovePaintingSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetGalleryPaintingSignal;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var requestBrowseGallery : RequestBrowseGallerySignal;

		[Inject]
		public var requestLovePaintingSignal : RequestLovePaintingSignal;

		[Inject]
		public var notifyLovePaintingSucceededSignal : NotifyLovePaintingSucceededSignal;

		[Inject]
		public var notifyLovePaintingFailedSignal : NotifyLovePaintingFailedSignal;

		[Inject]
		public var requestSetGalleryPaintingSignal : RequestSetGalleryPaintingSignal;

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

			requestSetGalleryPaintingSignal.add(onRequestSetGalleryPainting);
		}

		override public function destroy() : void
		{
			requestSetGalleryPaintingSignal.remove(onRequestSetGalleryPainting);
			super.destroy();
		}

		private function onRequestSetGalleryPainting(painting : GalleryImageProxy) : void
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
			// TODO:Should go back to previously active book state
			requestBrowseGallery.dispatch(GalleryType.MOST_RECENT);
		}

		private function lovePainting() : void
		{
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
			notifyLovePaintingFailedSignal.add(onLovePaintingFailed);
			notifyLovePaintingSucceededSignal.add(onLovePaintingSucceeded);
			requestLovePaintingSignal.dispatch(_activePainting.id);
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
