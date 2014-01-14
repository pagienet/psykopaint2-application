package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;

	import net.psykosoft.psykopaint2.core.models.GalleryType;

	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;

	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.services.CameraRollService;
	import net.psykosoft.psykopaint2.core.services.SampleImageService;
	import net.psykosoft.psykopaint2.core.services.SourceImageService;
	import net.psykosoft.psykopaint2.book.signals.RequestOpenBookSignal;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetBookOffScreenRatioSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class BookViewMediator extends Mediator
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
		public var notifyBookModuleDestroyedSignal:NotifyBookModuleDestroyedSignal;

		[Inject]
		public var requestOpenBookSignal:RequestOpenBookSignal;

		[Inject]
		public var cameraRollService:CameraRollService;

		[Inject]
		public var sampleImageService:SampleImageService;

		[Inject]
		public var galleryService:GalleryService;

		[Inject]
		public var requestSetBookOffScreenRatioSignal:RequestSetBookOffScreenRatioSignal;

		[Inject]
		public var requestNavigationStateChange:RequestNavigationStateChangeSignal;

		[Inject]
		public var requestDestroyBookModuleSignal:RequestDestroyBookModuleSignal;

		private var _currentGalleryType:int = -1;
		private var _sourceType:String;
		private var _galleryNavStateLookUp:Array;

		public function BookViewMediator()
		{
			_galleryNavStateLookUp = [];
			_galleryNavStateLookUp[GalleryType.FOLLOWING] = NavigationStateType.GALLERY_BROWSE_FOLLOWING;
			_galleryNavStateLookUp[GalleryType.MOST_LOVED] = NavigationStateType.GALLERY_BROWSE_MOST_LOVED;
			_galleryNavStateLookUp[GalleryType.MOST_RECENT] = NavigationStateType.GALLERY_BROWSE_MOST_RECENT;
			_galleryNavStateLookUp[GalleryType.YOURS] = NavigationStateType.GALLERY_BROWSE_YOURS;
		}

		override public function initialize():void
		{

			super.initialize();

			requestSetBookOffScreenRatioSignal.add(view.setHiddenOffScreenRatio);
			requestDestroyBookModuleSignal.add(onRequestDestroyBook);
			view.imageSelectedSignal.add(onImageSelected);
			view.galleryImageSelectedSignal.add(onGalleryImageSelected);
			view.onGalleryCollectionRequestedSignal.add(onGalleryCollectionRequest);
			view.onImageCollectionRequestedSignal.add(fetchImageCollection);
			view.bookHiddenSignal.add(onBookHidden);
			view.bookShownSignal.add(onBookShown);
			requestOpenBookSignal.add(onRequestOpenBookSignal);
			GpuRenderManager.addRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL);
		}

		override public function destroy():void
		{
			super.destroy();
			requestSetBookOffScreenRatioSignal.remove(view.setHiddenOffScreenRatio);
			view.imageSelectedSignal.remove(onImageSelected);
			view.galleryImageSelectedSignal.remove(onGalleryImageSelected);
			view.onGalleryCollectionRequestedSignal.remove(onGalleryCollectionRequest);
			view.onImageCollectionRequestedSignal.remove(fetchImageCollection);
			view.bookHiddenSignal.remove(onBookHidden);
			view.bookShownSignal.remove(onBookShown);
			requestOpenBookSignal.remove(onRequestOpenBookSignal);
			GpuRenderManager.removeRenderingStep(view.renderScene, GpuRenderingStepType.NORMAL);
		}

		private function onBookShown():void
		{
			if (_sourceType == ImageCollectionSource.GALLERY_IMAGES)
				requestNavigationStateChange.dispatch(_galleryNavStateLookUp[_currentGalleryType]);
		}

		private function onBookHidden():void
		{
			if (_sourceType == ImageCollectionSource.GALLERY_IMAGES)
				requestNavigationStateChange.dispatch(NavigationStateType.GALLERY_PAINTING);
		}

		private function onRequestOpenBookSignal(sourceType:String, galleryType:uint):void
		{
			_sourceType = sourceType;
			if (sourceType == ImageCollectionSource.GALLERY_IMAGES) {
				view.setHiddenMode();
				view.enableVerticalSwipe();
				onGalleryCollectionRequest(galleryType, 0, 30);
			}
			else {
				view.disableVerticalSwipe();

				if (sourceType == ImageCollectionSource.SAMPLE_IMAGES) {
					fetchImageCollection(sourceType, 0, 30);

				}
				else if (sourceType == ImageCollectionSource.CAMERAROLL_IMAGES) {
					fetchImageCollection(sourceType, 0, 80);
				}
			}
		}

		//to do dispatch request for next or previous collection
		private function onGalleryCollectionRequest(galleryType:uint, index:uint, amount:uint):void
		{
			galleryService.fetchImages(galleryType, index, amount, onGalleryImageCollectionFetched, onFetchImagesFailure);
		}

		private function fetchImageCollection(sourceType:String, index:uint, amount:uint):void
		{
			var service:SourceImageService = sourceType == ImageCollectionSource.CAMERAROLL_IMAGES ? cameraRollService : sampleImageService;
			service.fetchImages(index, amount, onSourceImagesFetched, onFetchImagesFailure);
		}

		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifySourceImageSelectedFromBookSignal.dispatch(selectedBmd);
		}

		private function onGalleryImageSelected(selectedGalleryImage:GalleryImageProxy):void
		{
			notifyGalleryImageSelected.dispatch(selectedGalleryImage);
			view.transitionToHiddenMode();
		}

		private function onRequestDestroyBook():void
		{
			view.bookHasClosedSignal.addOnce(onAnimateOutComplete);
			view.book.closePages();
		}

		private function onAnimateOutComplete():void
		{
			view.bookDisposedSignal.addOnce(onBookDisposed);
			view.dispose();
			view.parent.removeChild(view);
		}

		private function onBookDisposed():void
		{
			notifyBookModuleDestroyedSignal.dispatch();
		}

		private function onSourceImagesFetched(collection:SourceImageCollection):void
		{
			_currentGalleryType = -1;
			view.setSourceImages(collection);
		}

		private function onGalleryImageCollectionFetched(collection:GalleryImageCollection):void
		{
			view.setGalleryImageCollection(collection);

			_currentGalleryType = collection.type;

			if (collection.type != _currentGalleryType && collection.images.length > 0)
				notifyGalleryImageSelected.dispatch(collection.images[0]);
		}

		private function onFetchImagesFailure(statusCode:int):void
		{
			// TODO: handle
		}

		public function dispose():void
		{

		}
	}
}
