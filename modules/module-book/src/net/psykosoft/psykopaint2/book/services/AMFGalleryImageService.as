package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.book.model.FileGalleryImageProxy;
	import net.psykosoft.psykopaint2.book.model.GalleryImageCollection;
	import net.psykosoft.psykopaint2.book.model.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.model.GalleryType;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImagesFailedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.services.AMFBridge;

	public class AMFGalleryImageService implements GalleryImageService
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var userProxy : LoggedInUserProxy;

		[Inject]
		public var notifyGalleryImagesFetchedSignal : NotifyGalleryImagesFetchedSignal;

		[Inject]
		public var notifyGalleryImagesFailedSignal : NotifyGalleryImagesFailedSignal;

		public function AMFGalleryImageService()
		{
		}

		public function fetchImages(source : int, index : int, amount : int) : void
		{
			switch (source) {
				case GalleryType.YOURS:
					amfBridge.getUserImages(userProxy.userID, index, amount, onUserImagesSuccess, onFailed);
					break;
				case GalleryType.FOLLOWING:
					amfBridge.getFollowedUserImages(userProxy.userID, index, amount, onFollowedUserImagesSuccess, onFailed);
					break;
				case GalleryType.MOST_LOVED:
					amfBridge.getMostLovedImages(index, amount, onMostLovedSuccess, onFailed);
					break;
				case GalleryType.MOST_RECENT:
					amfBridge.getMostRecentPaintings(index, amount, onMostRecentSuccess, onFailed);
					break;
			}
		}

		private function onUserImagesSuccess(data : Object) : void
		{
			translateImages(GalleryType.YOURS, Array(data));
		}

		private function onFollowedUserImagesSuccess(data : Object) : void
		{
			translateImages(GalleryType.FOLLOWING, Array(data));
		}

		private function onMostLovedSuccess(data : Object) : void
		{
			translateImages(GalleryType.MOST_LOVED, Array(data));
		}

		private function onMostRecentSuccess(data : Object) : void
		{
			translateImages(GalleryType.MOST_RECENT, Array(data));
		}

		private function onFailed(data : Object) : void
		{
			notifyGalleryImagesFailedSignal.dispatch(data);
		}

		private function translateImages(type : uint, data : Array) : void
		{
			var collection : GalleryImageCollection = new GalleryImageCollection();
			collection.type = type;

			var len : int = data.length;
			for (var i : int = 0; i < len; ++i) {
				var obj : Object = data[i];
				var vo : FileGalleryImageProxy = new FileGalleryImageProxy();
				vo.id = obj["id"];
				vo.thumbnailFilename = obj["url_thumb200"];
				vo.userName = obj["name"];
				vo.numLikes = obj["num_favorite"];
				vo.numComments = obj["num_comments"];
				vo.paintingMode = obj["is_photo_painting"] == 1? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE;
				collection.images.push(vo);
			}

			notifyGalleryImagesFetchedSignal.dispatch(collection);
		}
	}
}
