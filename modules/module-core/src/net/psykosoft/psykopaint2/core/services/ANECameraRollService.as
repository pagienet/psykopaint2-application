package net.psykosoft.psykopaint2.core.services
{
	import flash.events.EventDispatcher;

	import net.psykosoft.photos.UserPhotosExtension;
	import net.psykosoft.psykopaint2.core.models.ANESourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;

	public class ANECameraRollService extends EventDispatcher implements CameraRollService
	{
		private var _ane : UserPhotosExtension;

		public function ANECameraRollService()
		{

		}

		public function fetchImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			if (!_ane) {
				_ane = new UserPhotosExtension();
				_ane.initialize(function() {
					doFetch(amount, index, onSuccess);
				});
			}
			else {
				doFetch(amount, index, onSuccess);
			}
		}

		private function doFetch(amount : int, index : int, onSuccess : Function) : void
		{
			var collection : SourceImageCollection = new SourceImageCollection();
			var imageCount : uint = _ane.getNumberOfLibraryItems();

			if (amount > 0)
				imageCount = Math.min(imageCount, index + amount);

			collection.source = ImageCollectionSource.CAMERAROLL_IMAGES;
			collection.index = index;
			collection.numTotalImages = imageCount;

			for (var i : int = index; i < imageCount; ++i) {
				var imageVO : ANESourceImageProxy = new ANESourceImageProxy(_ane);
				imageVO.id = i;
				collection.images.push(imageVO);
			}

			onSuccess(collection);
		}
	}
}
