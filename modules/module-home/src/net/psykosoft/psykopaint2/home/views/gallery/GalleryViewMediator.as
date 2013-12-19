package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetGalleryPaintingSignal;

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
			galleryService.fetchImages(source, index, 0, onRequestActiveImageResult, onImageCollectionFailed);
		}

		private function onStateChangeSignal(newState:String) : void
		{
			switch (newState) {
				case NavigationStateType.BOOK_GALLERY:
				case NavigationStateType.GALLERY_PAINTING:
//				case NavigationStateType.GALLERY_SHARE:	// probably not allowed to swipe when share is open
					view.initInteraction();
					break;
				default:
					view.stopInteraction();
			}
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
			view.setImmediateActiveImage(galleryImageProxy);
		}

		private function onInitialImageFetched(collection : GalleryImageCollection) : void
		{
			view.setImmediateActiveImage(collection.images[0]);
		}

		private function onRequestActiveImageResult(collection : GalleryImageCollection) : void
		{
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
