package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetBookOffScreenRatioSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetGalleryPaintingSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestUpdateGalleryPaintingMenuSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class GalleryViewMediator extends Mediator
	{
		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var view : GalleryView;

		[Inject]
		public var requestSetGalleryPaintingSignal : RequestSetGalleryPaintingSignal;

		[Inject]
		public var notifyStateChangeSignal:NotifyNavigationStateChangeSignal;

		[Inject]
		public var requestSetBookOffScreenRatioSignal : RequestSetBookOffScreenRatioSignal;

		[Inject]
		public var requestUpdateGalleryPaintingMenuSignal : RequestUpdateGalleryPaintingMenuSignal;

		public function GalleryViewMediator()
		{
		}

		override public function initialize() : void
		{
			super.initialize();
			requestSetGalleryPaintingSignal.add(onRequestSetGalleryPainting);
			notifyStateChangeSignal.add(onStateChangeSignal);
			view.requestImageCollection.add(requestImageCollection);
			view.requestActiveImageSignal.add(requestActiveImage);
			galleryService.fetchImages(GalleryType.MOST_RECENT, 0, 1, onInitialImageFetched, onImageCollectionFailed);
		}

		private function requestActiveImage(source : int, index : int) : void
		{
			galleryService.fetchImages(source, index, 1, onRequestActiveImageResult, onImageCollectionFailed);
		}

		private function onStateChangeSignal(newState:String) : void
		{
			switch (newState) {

				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
				case NavigationStateType.GALLERY_BROWSE_YOURS:
				case NavigationStateType.GALLERY_PAINTING:
//					// probably not allowed to swipe when share is open
					initInteraction();
					view.showHighQuality = true;
					break;
				case NavigationStateType.GALLERY_SHARE:
					view.showHighQuality = true;
					stopInteraction();
					break;
				default:
					view.showHighQuality = false;
					stopInteraction();
			}

		}

		private function stopInteraction() : void
		{
			if (view.onZoomUpdateSignal)
				view.onZoomUpdateSignal.remove(onZoomUpdate);
			view.stopInteraction();
		}

		private function initInteraction() : void
		{
			view.initInteraction();
			view.onZoomUpdateSignal.add(onZoomUpdate);
		}

		private function onZoomUpdate(ratio : Number) : void
		{
			requestSetBookOffScreenRatioSignal.dispatch(ratio);
		}

		override public function destroy() : void
		{
			super.destroy();
			requestSetGalleryPaintingSignal.remove(onRequestSetGalleryPainting);
			view.requestImageCollection.remove(requestImageCollection);
			view.requestActiveImageSignal.remove(requestActiveImage);
			view.dispose();
		}

		private function requestImageCollection(source : int, index : int, amount : int) : void
		{
			galleryService.fetchImages(source, index, amount, onImageColectionSuccess, onImageCollectionFailed);
		}

		private function onRequestSetGalleryPainting(galleryImageProxy : GalleryImageProxy) : void
		{
			requestUpdateGalleryPaintingMenuSignal.dispatch(galleryImageProxy);
			view.setImmediateActiveImage(galleryImageProxy);
		}

		private function onInitialImageFetched(collection : GalleryImageCollection) : void
		{
			requestUpdateGalleryPaintingMenuSignal.dispatch(collection.images[0]);
			view.setImmediateActiveImage(collection.images[0]);
		}

		private function onRequestActiveImageResult(collection : GalleryImageCollection) : void
		{
			requestUpdateGalleryPaintingMenuSignal.dispatch(collection.images[0]);
			view.setActiveImage(collection.images[0]);
		}

		private function onImageColectionSuccess(collection : GalleryImageCollection) : void
		{
			view.setImageCollection(collection);
		}

		private function onImageCollectionFailed() : void
		{
			// TODO: SHOW FEEDBACK
			trace ("Failed to fetch image collection!");
		}
	}
}
