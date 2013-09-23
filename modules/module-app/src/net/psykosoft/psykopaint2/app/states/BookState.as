package net.psykosoft.psykopaint2.app.states
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.model.GalleryImageRequestVO;
	import net.psykosoft.psykopaint2.book.model.SourceImageRequestVO;
	import net.psykosoft.psykopaint2.book.signals.NotifyImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchGalleryImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchSourceImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitGallerySignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRetrieveCameraImageSignal;

	public class BookState extends State
	{
		[Inject]
		public var requestNavigationStateChange : RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyImageSelectedFromBookSignal : NotifyImageSelectedFromBookSignal;

		[Inject]
		public var transitionToCropState : TransitionBookToCropState;

		[Inject]
		public var transitionToHomeState : TransitionBookToHomeState;

		[Inject]
		public var requestSetBookBackgroundSignal : RequestSetBookBackgroundSignal;

		[Inject]
		public var requestFetchSourceImagesSignal : RequestFetchSourceImagesSignal;

		[Inject]
		public var requestFetchGalleryImagesSignal : RequestFetchGalleryImagesSignal;

		[Inject]
		public var requestRetrieveCameraImageSignal:RequestRetrieveCameraImageSignal;

		[Inject]
		public var requestExitPickAnImageSignal:RequestExitPickAnImageSignal;

		[Inject]
		public var requestBrowseSampleImagesSignal : RequestBrowseSampleImagesSignal;

		[Inject]
		public var requestBrowseUserImagesSignal : RequestBrowseUserImagesSignal;

		[Inject]
		public var requestBrowseGallerySignal : RequestBrowseGallerySignal;

		[Inject]
		public var requestExitGallerySignal : RequestExitGallerySignal;

		private var _background : RefCountedTexture;
		private var _activeSourceType:String;
		private var _galleryType : uint;



		public function BookState()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			requestSetBookBackgroundSignal.add(onRequestSetCropBackgroundSignal);
		}

		private function onRequestSetCropBackgroundSignal(background : RefCountedTexture) : void
		{
			if (_background)
				_background.dispose();

			if (background)
				_background = background.newReference();
			else
				_background = null;
		}

		/**
		 *
		 * @param data An object containing:
		 * {
		 *  - source: String value of BookImageSource
		 *	- type: if BookImageSource == GALLERY, contains a value of GalleryType
		 *}
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			if (data.source == BookImageSource.GALLERY_IMAGES) {
				_galleryType = data.type;
				requestNavigationStateChange.dispatch(NavigationStateType.BOOK_GALLERY);
			}
			else
				requestNavigationStateChange.dispatch(NavigationStateType.BOOK_SOURCE_IMAGES);

			_activeSourceType = data.source;

			refreshBookSource();

			requestBrowseSampleImagesSignal.add(onBrowseSampleImagesSignal);
			requestBrowseUserImagesSignal.add(onBrowseUserImagesSignal);
			requestBrowseGallerySignal.add(onRequestBrowseGallerySignal);
			notifyImageSelectedFromBookSignal.add(onImageSelectedFromBookSignal);
			requestRetrieveCameraImageSignal.add(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.add(onRequestExitPickAnImageSignal);
			requestExitGallerySignal.add(onRequestExitGallerySignal);
		}

		private function onRequestBrowseGallerySignal(galleryID : uint) : void
		{
			if( _activeSourceType == BookImageSource.GALLERY_IMAGES && _galleryType == galleryID ) return;
			_galleryType = galleryID;

			refreshBookSource();
		}

		override ns_state_machine function deactivate() : void
		{
			if (_background)
				_background.dispose();

			_activeSourceType = null;
			_galleryType = 0;
			_background = null;
			requestBrowseSampleImagesSignal.remove(onBrowseSampleImagesSignal);
			requestBrowseUserImagesSignal.remove(onBrowseUserImagesSignal);
			requestBrowseGallerySignal.remove(onRequestBrowseGallerySignal);
			notifyImageSelectedFromBookSignal.remove(onImageSelectedFromBookSignal);
			requestRetrieveCameraImageSignal.remove(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.remove(onRequestExitPickAnImageSignal);
			requestExitGallerySignal.remove(onRequestExitGallerySignal);
		}

		private function onBrowseUserImagesSignal() : void
		{
			if( _activeSourceType == BookImageSource.USER_IMAGES ) return;
			_activeSourceType = BookImageSource.USER_IMAGES;

			refreshBookSource();
		}

		private function onBrowseSampleImagesSignal() : void
		{
			if( _activeSourceType == BookImageSource.SAMPLE_IMAGES ) return;
			_activeSourceType = BookImageSource.SAMPLE_IMAGES;

			refreshBookSource();
		}

		private function refreshBookSource():void {
			if (_activeSourceType == BookImageSource.GALLERY_IMAGES)
				requestFetchGalleryImagesSignal.dispatch(new GalleryImageRequestVO(_galleryType, 0, 24));
			else {
				requestFetchSourceImagesSignal.dispatch(new SourceImageRequestVO(_activeSourceType, 0, 48));
			}
		}

		private function onImageSelectedFromBookSignal(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToCropState, {bitmapData: bitmapData, background: _background.newReference()});
		}

		private function onRequestExitPickAnImageSignal():void {
			stateMachine.setActiveState(transitionToHomeState, { target: NavigationStateType.HOME_ON_EASEL });
		}

		private function onRequestExitGallerySignal() : void
		{
			stateMachine.setActiveState(transitionToHomeState, { target: NavigationStateType.HOME_ON_EASEL });
		}

		private function onRequestRetrieveCameraImageSignal():void {
			stateMachine.setActiveState(transitionToHomeState, { target: NavigationStateType.CAPTURE_IMAGE });
		}
	}
}
