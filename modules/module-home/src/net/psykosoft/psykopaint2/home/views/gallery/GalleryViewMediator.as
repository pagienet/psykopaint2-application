package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.NetworkFailureGalleryImageProxy;
	import net.psykosoft.psykopaint2.core.services.GalleryService;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryZoomRatioSignal;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class GalleryViewMediator extends Mediator
	{
		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		[Inject]
		public var view : GalleryView;

		[Inject]
		public var notifyStateChangeSignal:NotifyNavigationStateChangeSignal;

		[Inject]
		public var notifyGalleryZoomRatioSignal : NotifyGalleryZoomRatioSignal;

		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var notifyAMFConnectionFailed : NotifyAMFConnectionFailed;

		// keeps track whether or not the active painting update was triggered locally
		private var internalUpdate : Boolean;
		private var oldState:String;
		private var isInteractive:Boolean;
		private var _galleryNavStateLookUp:Array;

		public function GalleryViewMediator()
		{
			_galleryNavStateLookUp = [];
			_galleryNavStateLookUp[NavigationStateType.GALLERY_BROWSE_FOLLOWING] = GalleryType.FOLLOWING;
			_galleryNavStateLookUp[NavigationStateType.GALLERY_BROWSE_MOST_LOVED] = GalleryType.MOST_LOVED;
			_galleryNavStateLookUp[NavigationStateType.GALLERY_BROWSE_MOST_RECENT] = GalleryType.MOST_RECENT;
			_galleryNavStateLookUp[NavigationStateType.GALLERY_BROWSE_YOURS] = GalleryType.YOURS;
			_galleryNavStateLookUp[NavigationStateType.GALLERY_BROWSE_USER] = GalleryType.USER;
		}

		override public function initialize() : void
		{
			super.initialize();
			notifyAMFConnectionFailed.add(onImageCollectionFailed);
			activePaintingModel.onUpdate.add(onActivePaintingUpdate);
			notifyStateChangeSignal.add(onStateChangeSignal);
			view.requestImageCollection.add(requestImageCollection);
			view.requestActiveImageSignal.add(onRequestActiveImage);
			view.requestReconnectSignal.add(onRequestReconnect);
			requestActiveImage(GalleryType.MOST_RECENT, 0);
		}

		override public function destroy() : void
		{
			super.destroy();
			notifyAMFConnectionFailed.remove(onImageCollectionFailed);
			activePaintingModel.onUpdate.remove(onActivePaintingUpdate);
			notifyStateChangeSignal.remove(onStateChangeSignal);
			view.requestImageCollection.remove(requestImageCollection);
			view.requestActiveImageSignal.remove(requestActiveImage);
			view.requestReconnectSignal.remove(onRequestReconnect);
			view.dispose();
		}

		private function onRequestActiveImage(source : int, index : int) : void
		{
			internalUpdate = true;
			requestActiveImage(source, index);
		}

		private function requestActiveImage(source : int, index : int) : void
		{
			galleryService.fetchImages(source, index, 1, onRequestActiveImageResult, onImageCollectionFailed);
		}

		private function onRequestReconnect() : void
		{
			requestActiveImage(GalleryType.MOST_RECENT, 0);
		}

		private function onStateChangeSignal(newState:String) : void
		{
			switch (newState) {
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
				case NavigationStateType.GALLERY_BROWSE_YOURS:
				case NavigationStateType.GALLERY_BROWSE_USER:
				case NavigationStateType.GALLERY_PAINTING:
					// probably not allowed to swipe when share is open
					initInteraction();
					view.showHighQuality = true;
					if (oldState != NavigationStateType.GALLERY_PAINTING && _galleryNavStateLookUp[oldState] != _galleryNavStateLookUp[newState]) {
						resetPaintings(_galleryNavStateLookUp[newState]);
					}
					break;
				case NavigationStateType.GALLERY_SHARE:
					view.showHighQuality = true;
					stopInteraction();
					break;
				default:
					view.showHighQuality = false;
					stopInteraction();
			}
			oldState = newState;
		}

		private function resetPaintings(source:uint):void
		{
			requestActiveImage(source, 0);
		}

		private function stopInteraction() : void
		{
			if (isInteractive) {
				if (view.onZoomUpdateSignal)
					view.onZoomUpdateSignal.remove(onZoomUpdate);
				view.stopInteraction();
				isInteractive = false;
			}
		}

		private function initInteraction() : void
		{
			if (!isInteractive) {
				view.initInteraction();
				view.onZoomUpdateSignal.add(onZoomUpdate);
				isInteractive = true;
			}
		}

		private function onZoomUpdate(ratio : Number) : void
		{
			requestNavigationToggleSignal.dispatch(ratio > .9? -1 : 1, true, false);
			notifyGalleryZoomRatioSignal.dispatch(ratio);
		}

		private function requestImageCollection(source : int, index : int, amount : int) : void
		{
			galleryService.fetchImages(source, index, amount, onImageColectionSuccess, onImageCollectionFailed);
		}

		private function onRequestActiveImageResult(collection : GalleryImageCollection) : void
		{
			activePaintingModel.painting = collection.images.length > 0? collection.images[0] : null;
		}

		private function onActivePaintingUpdate() : void
		{
			if (internalUpdate)
				view.setActiveImage(activePaintingModel.painting);
			else
				view.setImmediateActiveImage(activePaintingModel.painting);

			internalUpdate = false;
		}

		private function onImageColectionSuccess(collection : GalleryImageCollection) : void
		{
			view.setImageCollection(collection);
		}

		private function onImageCollectionFailed(status : uint) : void
		{
			view.setImageCollection(generateNetworkFailureCollection());
		}

		private function generateNetworkFailureCollection():GalleryImageCollection
		{
			var imageProxy : NetworkFailureGalleryImageProxy = new NetworkFailureGalleryImageProxy();

			var collection : GalleryImageCollection = new GalleryImageCollection();
			collection.type = GalleryType.NONE;
			collection.numTotalPaintings = 1;
			collection.images.push(imageProxy);

			return collection;
		}
	}
}
