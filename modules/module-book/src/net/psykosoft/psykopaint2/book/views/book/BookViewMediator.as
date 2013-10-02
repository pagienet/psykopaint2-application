package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.BookImageSource;

	import net.psykosoft.psykopaint2.book.model.SourceImageCollection;
	import net.psykosoft.psykopaint2.book.model.SourceImageRequestVO;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchGalleryImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchSourceImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestOpenBookSignal;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageRequestVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
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
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		[Inject]
		public var notifyBookModuleDestroyedSignal : NotifyBookModuleDestroyedSignal;

		[Inject]
		public var notifyGalleryImagesFetchedSignal : NotifyGalleryImagesFetchedSignal;

		[Inject]
		public var requestOpenBookSignal : RequestOpenBookSignal;

		[Inject]
		public var requestFetchSourceImagesSignal : RequestFetchSourceImagesSignal;

		[Inject]
		public var requestFetchGalleryImagesSignal : RequestFetchGalleryImagesSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			registerEnablingState( NavigationStateType.BOOK_SOURCE_IMAGES );
			registerEnablingState( NavigationStateType.BOOK_GALLERY );

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
			requestAnimateBookOutSignal.add(onRequestAnimateBookOutSignal);
			notifySourceImagesFetchedSignal.add(onSourceImagesFetched);
			notifyGalleryImagesFetchedSignal.add(onGalleryImageCollectionFetched);
			requestOpenBookSignal.add(onRequestOpenBookSignal);
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onDisabled() : void
		{
			view.imageSelectedSignal.remove(onImageSelected);
			view.galleryImageSelectedSignal.remove(onGalleryImageSelected);
			view.onGalleryCollectionRequestedSignal.remove(onGalleryCollectionRequest);
			view.onImageCollectionRequestedSignal.remove(onImageCollectionRequest);
			requestAnimateBookOutSignal.remove(onRequestAnimateBookOutSignal);
			notifySourceImagesFetchedSignal.remove(onSourceImagesFetched);
			notifyGalleryImagesFetchedSignal.remove(onGalleryImageCollectionFetched);
			requestOpenBookSignal.remove(onRequestOpenBookSignal);
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onRequestOpenBookSignal(sourceType : String, galleryType : uint) : void
		{
			if (sourceType == BookImageSource.GALLERY_IMAGES){
				onGalleryCollectionRequest(galleryType, 0, 30);

			} else if(sourceType == BookImageSource.SAMPLE_IMAGES){
				onImageCollectionRequest(sourceType, 0, 30);

			} else if(sourceType == BookImageSource.CAMERA_IMAGES){
				onImageCollectionRequest(sourceType, 0, 80);
			}
		}

		//to do dispatch request for next or previous collection
		private function onGalleryCollectionRequest(galleryType : uint, fromIndex : uint, max : uint) : void
		{
			requestFetchGalleryImagesSignal.dispatch(new GalleryImageRequestVO(galleryType, fromIndex, max));
		}
		private function onImageCollectionRequest(sourceType : String, fromIndex : uint, max : uint) : void
		{
			requestFetchSourceImagesSignal.dispatch(new SourceImageRequestVO(sourceType, fromIndex, max));
		}


		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifySourceImageSelectedFromBookSignal.dispatch( selectedBmd );
		}

		private function onGalleryImageSelected(selectedGalleryImage : GalleryImageProxy) : void
		{
			notifyGalleryImageSelected.dispatch(selectedGalleryImage);
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
			view.setSourceImages(collection);
		}
		private function onGalleryImageCollectionFetched(collection : GalleryImageCollection) : void
		{
			view.setGalleryImageCollection(collection);
		}

		
	}
}
