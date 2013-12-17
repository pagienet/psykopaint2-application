package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.GalleryType;

	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;

	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.services.CameraRollService;
	import net.psykosoft.psykopaint2.core.services.SampleImageService;
	import net.psykosoft.psykopaint2.core.services.SourceImageService;
	import net.psykosoft.psykopaint2.book.signals.RequestOpenBookSignal;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var notifySourceImageSelectedFromBookSignal:NotifySourceImageSelectedFromBookSignal;

		[Inject]
		public var notifyGalleryImageSelected:NotifyGalleryImageSelectedFromBookSignal;

		[Inject]
		public var requestAnimateBookOutSignal : RequestAnimateBookOutSignal;

		[Inject]
		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

		[Inject]
		public var notifyBookModuleDestroyedSignal : NotifyBookModuleDestroyedSignal;

		[Inject]
		public var requestOpenBookSignal : RequestOpenBookSignal;

		[Inject]
		public var cameraRollService : CameraRollService;

		[Inject]
		public var sampleImageService : SampleImageService;

		[Inject]
		public var galleryService : GalleryService;

		private var _currentGalleryType : int = -1;
		private var _sourceType : String;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			registerEnablingState( NavigationStateType.BOOK_SOURCE_IMAGES );
			registerEnablingState( NavigationStateType.BOOK_GALLERY );
			registerEnablingState( NavigationStateType.GALLERY_PAINTING );

			view.stage3dProxy = stage3dProxy;

			view.enabledSignal.add(onEnabled);
			view.disabledSignal.add(onDisabled);
			view.bookDisposedSignal.add( onBookDisposed );
		}

		private function onBookDisposed():void {
			notifyBookModuleDestroyedSignal.dispatch();
		}

		override public function destroy() : void
		{
			super.destroy();
			view.enabledSignal.remove(onEnabled);
			view.disabledSignal.remove(onDisabled);
		}

		private function onEnabled() : void
		{
			view.imageSelectedSignal.add(onImageSelected);
			view.galleryImageSelectedSignal.add(onGalleryImageSelected);
			view.onGalleryCollectionRequestedSignal.add(onGalleryCollectionRequest);
			view.onImageCollectionRequestedSignal.add(onImageCollectionRequest);
			view.bookHiddenSignal.add(onBookHidden);
			view.bookShownSignal.add(onBookShown);
			requestAnimateBookOutSignal.add(onRequestAnimateBookOutSignal);
			requestOpenBookSignal.add(onRequestOpenBookSignal);
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onBookShown() : void
		{
			if (_sourceType == ImageCollectionSource.GALLERY_IMAGES)
				requestNavigationStateChange(NavigationStateType.BOOK_GALLERY);
		}

		private function onBookHidden() : void
		{
			if (_sourceType == ImageCollectionSource.GALLERY_IMAGES)
				requestNavigationStateChange(NavigationStateType.GALLERY_PAINTING);
		}

		private function onDisabled() : void
		{
			view.imageSelectedSignal.remove(onImageSelected);
			view.galleryImageSelectedSignal.remove(onGalleryImageSelected);
			view.onGalleryCollectionRequestedSignal.remove(onGalleryCollectionRequest);
			view.onImageCollectionRequestedSignal.remove(onImageCollectionRequest);
			view.bookHiddenSignal.remove(onBookHidden);
			view.bookShownSignal.remove(onBookShown);
			requestAnimateBookOutSignal.remove(onRequestAnimateBookOutSignal);
			requestOpenBookSignal.remove(onRequestOpenBookSignal);
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onRequestOpenBookSignal(sourceType : String, galleryType : uint) : void
		{
			_sourceType = sourceType;
			if (sourceType == ImageCollectionSource.GALLERY_IMAGES){
				view.setHiddenMode();
				view.enableVerticalSwipe();
				onGalleryCollectionRequest(galleryType, 0, 30);
			}
			else {
				view.disableVerticalSwipe();

				if(sourceType == ImageCollectionSource.SAMPLE_IMAGES){
					onImageCollectionRequest(sourceType, 0, 30);

				}
				else if(sourceType == ImageCollectionSource.CAMERAROLL_IMAGES){
					onImageCollectionRequest(sourceType, 0, 80);
				}
			}
		}

		//to do dispatch request for next or previous collection
		private function onGalleryCollectionRequest(galleryType : uint, index : uint, amount : uint) : void
		{
			galleryService.fetchImages(galleryType, index, amount, onGalleryImageCollectionFetched, onFetchImagesFailure);
		}

		private function onImageCollectionRequest(sourceType : String, index : uint, amount : uint) : void
		{
			var service : SourceImageService = sourceType == ImageCollectionSource.CAMERAROLL_IMAGES? cameraRollService : sampleImageService;
			service.fetchImages(index, amount, onSourceImagesFetched, onFetchImagesFailure);
		}

		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifySourceImageSelectedFromBookSignal.dispatch( selectedBmd );
		}

		private function onGalleryImageSelected(selectedGalleryImage : GalleryImageProxy) : void
		{
			notifyGalleryImageSelected.dispatch(selectedGalleryImage);
			view.transitionToHiddenMode();
		}

		private function onRequestAnimateBookOutSignal() : void
		{
			view.bookHasClosedSignal.addOnce(onAnimateOutComplete);
			view.book.closePages();
		}

		private function onAnimateOutComplete() : void
		{
			notifyAnimateBookOutCompleteSignal.dispatch();
		}

		private function onSourceImagesFetched(collection : SourceImageCollection) : void
		{
			_currentGalleryType = -1;
			view.setSourceImages(collection);
		}

		private function onGalleryImageCollectionFetched(collection : GalleryImageCollection) : void
		{
			view.setGalleryImageCollection(collection);

			if (collection.type != _currentGalleryType && collection.images.length > 0)
				notifyGalleryImageSelected.dispatch(collection.images[0]);
		}

		private function onFetchImagesFailure(statusCode : int) : void
		{
			// TODO: handle
		}
	}
}
