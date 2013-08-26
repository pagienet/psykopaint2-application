package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.photos.UserPhotosExtension;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;

	public class ANECameraRollService implements CameraRollService
	{
		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		private var _aneReady : Boolean;
		private var _ane : UserPhotosExtension;
		private var _indexToFetch : int;
		private var _amountToFetch : int;

		public function ANECameraRollService()
		{

		}

		public function fetchImages(index : int, amount : int) : void
		{
			_indexToFetch = index;
			_amountToFetch = amount;
			if (!_aneReady) {
				if (!_ane) initANE();
			}
			else
				getImages();
		}

		private function initANE() : void
		{
			_aneReady = true;
			_ane = new UserPhotosExtension();
			_ane.initialize(getImages);
		}

		private function getImages() : void
		{

		}
	}
}
