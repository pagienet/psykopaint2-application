package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestOpenBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;

	// not really a state, but an overlap
	// this is just so not everything clutters up HomeState, basically
	public class BookStateLayer
	{
		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

		[Inject]
		public var requestSetUpBookModuleSignal : RequestSetUpBookModuleSignal;

		[Inject]
		public var requestOpenBookSignal : RequestOpenBookSignal;

		[Inject]
		public var notifySourceImageSelectedFromBookSignal : NotifySourceImageSelectedFromBookSignal;

		[Inject]
		public var notifyGalleryImageSelectedSignal : NotifyGalleryImageSelectedFromBookSignal;

		[Inject]
		public var notifyBookModuleDestroyedSignal : NotifyBookModuleDestroyedSignal;

		[Inject]
		public var requestCropSourceImageSignal : RequestCropSourceImageSignal;

		[Inject]
		public var activePaintingModel : ActiveGalleryPaintingModel;

		private var _bookOpen:Boolean;
		private var _bookSourceType:String;
		private var _galleryType:int;

		private var _onBookDestroyedCallback : Function;

		public function BookStateLayer()
		{
		}

		public function show(source:String, galleryID : uint = 0) : void
		{
			if (source == _bookSourceType && _galleryType == galleryID) return;

			_bookSourceType = source;
			_galleryType = galleryID;

			if (!_bookOpen) {
				notifyBookModuleSetUpSignal.addOnce(onBookModuleSetUp);
				requestSetUpBookModuleSignal.dispatch();
			}
			else {
				refreshBookSource();
			}

			notifySourceImageSelectedFromBookSignal.add(onImageSelectedFromBookSignal);
			notifyGalleryImageSelectedSignal.add(onGalleryImageSelected);

			_bookOpen = true;
		}

		public function hide() : void
		{
			if (!_bookOpen) return;
			_bookOpen = false;
			_bookSourceType = null;
			notifySourceImageSelectedFromBookSignal.remove(onImageSelectedFromBookSignal);
			notifyGalleryImageSelectedSignal.remove(onGalleryImageSelected);
			notifyBookModuleDestroyedSignal.addOnce(onBookDestroyed);
			requestDestroyBookModuleSignal.dispatch();
		}

		private function onBookDestroyed() : void
		{
			_galleryType = -1;
			if (_onBookDestroyedCallback) _onBookDestroyedCallback();
			_onBookDestroyedCallback = null;
		}

		private function onBookModuleSetUp() : void
		{
			refreshBookSource();
		}

		private function refreshBookSource():void
		{
			requestOpenBookSignal.dispatch(_bookSourceType, _galleryType);
		}

		private function onImageSelectedFromBookSignal(bitmapData : BitmapData) : void
		{
			_onBookDestroyedCallback = function() : void {
				requestCropSourceImageSignal.dispatch(bitmapData, CameraRollImageOrientation.ROTATION_0);
			}

			hide();
		}

		private function onGalleryImageSelected(selectedGalleryImage : GalleryImageProxy) : void
		{
			activePaintingModel.painting = selectedGalleryImage;
		}
	}
}
