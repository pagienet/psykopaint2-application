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
	import net.psykosoft.psykopaint2.home.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRetrieveCameraImageSignal;

	public class BookState extends State
	{
		[Inject]
		public var requestStateChange : RequestNavigationStateChangeSignal;

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

//		[Inject]
//		public var requestBrowseSampleImagesSignal : RequestBrowseSampleImagesSignal;

//		[Inject]
//		public var requestBrowseUserImagesSignal : RequestBrowseUserImagesSignal;

//		[Inject]
//		public var requestAnimateBookOutSignal : RequestAnimateBookOutSignal;

//		[Inject]
//		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

//		[Inject]
//		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

//		[Inject]
//		public var notifyBookModuleDestroyedSignal:NotifyBookModuleDestroyedSignal;

//		[Inject]
//		public var transitionToBookState : TransitionHomeToBookState;

		private var _background : RefCountedTexture;
		private var _activeSourceType:String;

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
			requestStateChange.dispatch(NavigationStateType.BOOK);

			_activeSourceType = data.source;

			if (_activeSourceType == BookImageSource.GALLERY_IMAGES)
				requestFetchGalleryImagesSignal.dispatch(new GalleryImageRequestVO(data.type, 0, 16));
			else
				requestFetchSourceImagesSignal.dispatch(new SourceImageRequestVO(data.source, 0, 0));

//			requestBrowseSampleImagesSignal.add(onBrowseSampleImagesSignal);
//			requestBrowseUserImagesSignal.add(onBrowseUserImagesSignal);
			notifyImageSelectedFromBookSignal.add(onImageSelectedFromBookSignal);
			requestRetrieveCameraImageSignal.add(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.add(onRequestExitPickAnImageSignal);
		}

		override ns_state_machine function deactivate() : void
		{
			if (_background)
				_background.dispose();
			_background = null;
//			requestBrowseSampleImagesSignal.remove(onBrowseSampleImagesSignal);
//			requestBrowseUserImagesSignal.remove(onBrowseUserImagesSignal);
			notifyImageSelectedFromBookSignal.remove(onImageSelectedFromBookSignal);
			requestRetrieveCameraImageSignal.remove(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.remove(onRequestExitPickAnImageSignal);
		}

//		private function onBrowseUserImagesSignal() : void
//		{
//			if( _activeSourceType == BookImageSource.USER_IMAGES ) return;
//
//			_activeSourceType = BookImageSource.USER_IMAGES;
//			notifyAnimateBookOutCompleteSignal.addOnce(onAnimateBookOutComplete);
//			requestAnimateBookOutSignal.dispatch();
//		}

//		private function onBrowseSampleImagesSignal() : void
//		{
//			if( _activeSourceType == BookImageSource.SAMPLE_IMAGES ) return;
//
//			_activeSourceType = BookImageSource.SAMPLE_IMAGES;
//			notifyAnimateBookOutCompleteSignal.addOnce(onAnimateBookOutComplete);
//			requestAnimateBookOutSignal.dispatch();
//		}

//		private function onAnimateBookOutComplete() : void
//		{
//			notifyBookModuleDestroyedSignal.addOnce( onBookModuleDestroyed );
//			requestDestroyBookModuleSignal.dispatch();
//		}

//		private function onBookModuleDestroyed():void {
//			if( _activeSourceType == BookImageSource.USER_IMAGES ) {
//				if (CoreSettings.RUNNING_ON_iPAD)
//					stateMachine.setActiveState(transitionToBookState, BookImageSource.USER_IMAGES);
//				else
//					requestStateChange.dispatch(NavigationStateType.PICK_USER_IMAGE_DESKTOP);
//			}
//			else if( _activeSourceType == BookImageSource.SAMPLE_IMAGES ) {
//				stateMachine.setActiveState(transitionToBookState, BookImageSource.SAMPLE_IMAGES);
//			}
//		}

		private function onImageSelectedFromBookSignal(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToCropState, {bitmapData: bitmapData, background: _background.newReference()});
		}

		private function onRequestExitPickAnImageSignal():void {
			stateMachine.setActiveState(transitionToHomeState, { target: NavigationStateType.HOME_ON_EASEL });
		}

		private function onRequestRetrieveCameraImageSignal():void {
			stateMachine.setActiveState(transitionToHomeState, { target: NavigationStateType.CAPTURE_IMAGE });
		}
	}
}
