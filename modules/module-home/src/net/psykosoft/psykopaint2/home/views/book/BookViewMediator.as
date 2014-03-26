package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;

	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.core.services.CameraRollService;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.services.SampleImageService;
	import net.psykosoft.psykopaint2.core.services.SourceImageService;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryView;
	import net.psykosoft.psykopaint2.home.views.home.EaselView;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class BookViewMediator extends Mediator
	{
		[Inject]
		public var view : BookView;

		[Inject]
		public var notifyStateChange : NotifyNavigationStateChangeSignal;

		[Inject]
		public var cameraRollService:CameraRollService;

		[Inject]
		public var sampleImageService:SampleImageService;

		[Inject]
		public var galleryService:GalleryService;

		[Inject]
		public var requestCropSourceImageSignal : RequestCropSourceImageSignal;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		[Inject]
		public var requestNavigationStateChange:RequestNavigationStateChangeSignal;

		private var currentState:String;
		private var _gallerySource:int = -1;


		public function BookViewMediator()
		{
		}

		override public function initialize():void
		{
			view.init();
			view.galleryImageSelected.add(onGalleryImageSelected);
			view.sourceImageSelected.add(onSourceImageSelected);
			notifyStateChange.add(onStateChange);
		}

		override public function destroy():void
		{
			view.dispose();
			view.galleryImageSelected.remove(onGalleryImageSelected);
			view.sourceImageSelected.remove(onSourceImageSelected);
			notifyStateChange.remove(onStateChange);
		}

		private function onStateChange(newState : String) : void
		{
			if (newState == currentState) return;

			switch(newState) {
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
					showGalleryBook(GalleryType.FOLLOWING);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
					showGalleryBook(GalleryType.MOST_LOVED);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
					showGalleryBook(GalleryType.MOST_RECENT);
					break;
				case NavigationStateType.GALLERY_BROWSE_USER:
					showGalleryBook(GalleryType.USER);
					break;
				case NavigationStateType.GALLERY_BROWSE_YOURS:
					showGalleryBook(GalleryType.YOURS);
					break;
				case NavigationStateType.GALLERY_PAINTING:
					showGalleryBookBottom();
					break;
				case NavigationStateType.PICK_SAMPLE_IMAGE:
					showEaselBook(ImageCollectionSource.SAMPLE_IMAGES);
					break;
				case NavigationStateType.PICK_USER_IMAGE_IOS:
					showEaselBook(ImageCollectionSource.CAMERAROLL_IMAGES);
					break;
				default:
					_gallerySource = -1;
					view.hide();
			}

			currentState = newState;
		}

		private function showEaselBook(source:String):void
		{
			view.setBookPosition(EaselView.CAMERA_POSITION);
			view.mouseEnabled = true;
			view.show();
			var service:SourceImageService = source == ImageCollectionSource.CAMERAROLL_IMAGES ? cameraRollService : sampleImageService;
			service.fetchImages(0, 30, onSourceImagesFetched, onImagesError);
		}

		private function showGalleryBook(source : uint):void
		{
			var vector : Vector3D = GalleryView.CAMERA_FAR_POSITION;
			view.setBookPosition(vector);
			view.mouseEnabled = true;
			view.show();

			// this just prevents reloading between hidden and shown state
			if (_gallerySource != source) {
				_gallerySource = source;
				galleryService.fetchImages(source, 0, 30, onGalleryImagesFetched, onImagesError);
			}
		}

		private function showGalleryBookBottom():void
		{
			var vector : Vector3D = GalleryView.CAMERA_FAR_POSITION.clone();
			vector.y -= 185;
			view.setBookPosition(vector);
			view.mouseEnabled = true;
			view.show();
		}

		private function onSourceImagesFetched(collection:SourceImageCollection):void
		{
			view.setSourceImages(collection);
		}

		private function onGalleryImagesFetched(collection:GalleryImageCollection):void
		{
			view.setGalleryImageCollection(collection);
		}

		private function onImagesError(statusCode:int):void
		{
			// TODO: handle error
		}

		private function onGalleryImageSelected(galleryImageProxy : GalleryImageProxy) : void
		{
			activePaintingModel.painting = galleryImageProxy;
			requestNavigationStateChange.dispatch(NavigationStateType.GALLERY_PAINTING);
		}

		private function onSourceImageSelected(sourceImageProxy : SourceImageProxy) : void
		{
			view.mouseEnabled = false;
			view.hide();
			sourceImageProxy.loadFullSized(onLoadFullSizedSourceComplete, onLoadFullSizedError);
		}

		private function onLoadFullSizedError():void
		{
			// prevent further clicking
			view.mouseEnabled = true;
		}

		private function onLoadFullSizedSourceComplete(bitmapData : BitmapData):void
		{
			requestCropSourceImageSignal.dispatch(bitmapData, CameraRollImageOrientation.ROTATION_0);
		}
	}
}
