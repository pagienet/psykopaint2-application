package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
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

		public function GalleryViewMediator()
		{
		}

		override public function initialize() : void
		{
			super.initialize();
			requestSetGalleryPaintingSignal.add(onRequestSetGalleryPainting);
			view.requestImageCollection.add(onRequestImageCollection);
		}

		override public function destroy() : void
		{
			super.destroy();
			requestSetGalleryPaintingSignal.remove(onRequestSetGalleryPainting);
			view.requestImageCollection.remove(onRequestImageCollection);
			view.dispose();
		}

		private function onRequestImageCollection(source : int, index : int, amount : int) : void
		{
			galleryService.fetchImages(source, index, amount, onImageColectionSuccess, onImageCollectionFailed);
		}

		private function onRequestSetGalleryPainting(galleryImageProxy : GalleryImageProxy) : void
		{
			view.setActiveImage(galleryImageProxy);
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
