package net.psykosoft.psykopaint2.home.views.book
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

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
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryZoomRatioSignal;
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

		[Inject]
		public var notifyGalleryZoomRatioSignal : NotifyGalleryZoomRatioSignal;

		private var currentState:String;
		private var _gallerySource:int = -1;
		private var _activeGalleryNavState:String;
		private var _galleryZoomRatio:Number;


		public function BookViewMediator()
		{
		}

		override public function initialize():void
		{
			view.init();
			view.galleryImageSelected.add(onGalleryImageSelected);
			view.sourceImageSelected.add(onSourceImageSelected);
			view.switchedToNormalMode.add(onSwitchedToNormalMode);
			view.switchedToHiddenMode.add(onSwitchedToHiddenMode);
			notifyStateChange.add(onStateChange);
			notifyGalleryZoomRatioSignal.add(onGalleryZoomRatioSignal);
		}

		override public function destroy():void
		{
			view.dispose();
			view.galleryImageSelected.remove(onGalleryImageSelected);
			view.sourceImageSelected.remove(onSourceImageSelected);
			view.switchedToNormalMode.remove(onSwitchedToNormalMode);
			view.switchedToHiddenMode.remove(onSwitchedToHiddenMode);
			notifyStateChange.remove(onStateChange);
			notifyGalleryZoomRatioSignal.remove(onGalleryZoomRatioSignal);
		}

		private function onStateChange(newState : String) : void
		{
			if (newState == currentState) return;

			switch(newState) {
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
					showGalleryBook(newState, GalleryType.FOLLOWING);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
					showGalleryBook(newState, GalleryType.MOST_LOVED);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
					showGalleryBook(newState, GalleryType.MOST_RECENT);
					break;
				case NavigationStateType.GALLERY_BROWSE_USER:
					showGalleryBook(newState, GalleryType.USER);
					break;
				case NavigationStateType.GALLERY_BROWSE_YOURS:
					showGalleryBook(newState, GalleryType.YOURS);
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
					_activeGalleryNavState = null;
					view.mouseEnabled = false;
					view.hidingEnabled = false;
					view.remove();
			}

			currentState = newState;
		}

		private function showEaselBook(source:String):void
		{
			view.setBookPosition(EaselView.CAMERA_POSITION);
			view.hidingEnabled = false;
			view.bookEnabled = true;
			view.hiddenRatio = 1.5;
			TweenLite.to(view, .4, {hiddenRatio: 0.0, ease: Quad.easeOut});
			view.show();
			var service:SourceImageService = source == ImageCollectionSource.CAMERAROLL_IMAGES ? cameraRollService : sampleImageService;
			service.fetchImages(0, 30, onSourceImagesFetched, onImagesError);
		}

		private function showGalleryBook(galleryNavState : String, source : uint):void
		{
			// if _activeGalleryNavState == null, we're newly arriving in the gallery, so we need to show the book
			if (_activeGalleryNavState == null)
				view.hiddenRatio = 1.5;

			_activeGalleryNavState = galleryNavState;

			view.setBookPosition(GalleryView.CAMERA_FAR_POSITION);
			TweenLite.to(view, .4, {hiddenRatio: 0.0, ease: Quad.easeOut});
			view.bookEnabled = true;
			view.hidingEnabled = true;
			view.show();

			// this just prevents reloading between hidden and shown state
			if (_gallerySource != source) {
				_gallerySource = source;
				galleryService.fetchImages(source, 0, 30, onGalleryImagesFetched, onImagesError);
			}
		}

		private function onGalleryZoomRatioSignal(value : Number):void
		{
			if (_galleryZoomRatio == value) return;

			// the travel factor causes the book not to stay equidistant from the camera,
			// still generating a *slight* parallax effect without it becoming too big for the screen
			const travelFactor : Number = .9;

			var position : Vector3D = new Vector3D();
			position.x = GalleryView.CAMERA_FAR_POSITION.x;
			position.y = GalleryView.CAMERA_FAR_POSITION.y;
			position.z = GalleryView.CAMERA_FAR_POSITION.z + value*(GalleryView.CAMERA_NEAR_POSITION.z - GalleryView.CAMERA_FAR_POSITION.z) * travelFactor;
			view.setBookPosition(position);

			if (value < 0.25) {
				view.hidingEnabled = true;
				view.bookEnabled = true;

				// zoom all the way out -> show book fully
				// otherwise, show book hidden
				TweenLite.to(view, .4, {hiddenRatio: value == 0.0? 0.0 : 1.0, ease: Quad.easeOut});
			}
			else {
				view.hidingEnabled = false;
				view.bookEnabled = false;
				// setting hidden ratio > 1.0 will make it go further offscreen
				TweenLite.to(view, .4, {hiddenRatio: 1.5, ease: Quad.easeOut});
			}

			_galleryZoomRatio = value;
		}

		private function showGalleryBookBottom():void
		{
			view.setBookPosition(GalleryView.CAMERA_FAR_POSITION);
			TweenLite.to(view, .4, {hiddenRatio: 1.0, ease: Quad.easeOut});
			view.bookEnabled = true;
			view.hidingEnabled = true;
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
			TweenLite.to(view, .4, {
				hiddenRatio: 1.5,
				ease: Quad.easeOut,
				onComplete: function():void
				{
					view.remove();
					sourceImageProxy.loadFullSized(onLoadFullSizedSourceComplete, onLoadFullSizedError);
				}
			});
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

		private function onSwitchedToHiddenMode():void
		{
			requestNavigationStateChange.dispatch(NavigationStateType.GALLERY_PAINTING);
		}

		private function onSwitchedToNormalMode():void
		{
			requestNavigationStateChange.dispatch(_activeGalleryNavState);
		}
	}
}
