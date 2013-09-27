package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryServiceCallSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryServiceCallFailedSignal;

	public class AMFGalleryService implements GalleryService
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var userProxy : LoggedInUserProxy;

		[Inject]
		public var notifyGalleryImagesFetchedSignal : NotifyGalleryImagesFetchedSignal;

		[Inject]
		public var notifyGalleryImagesFailedSignal : NotifyGalleryImagesFailedSignal;

		[Inject]
		public var notifyGalleryServiceCallSucceededSignal : NotifyGalleryServiceCallSucceededSignal;

		[Inject]
		public var notifyGalleryServiceCallFailedSignal : NotifyGalleryServiceCallFailedSignal;

		private var _index : int;

		public function AMFGalleryService()
		{
		}

		public function fetchImages(source : int, index : int, amount : int) : void
		{
			switch (source) {
				case GalleryType.YOURS:
					amfBridge.getUserImages(userProxy.userID, index, amount, onUserImagesSuccess, onFailed);
					break;
				case GalleryType.FOLLOWING:
					amfBridge.getFollowedUserImages(userProxy.sessionID, index, amount, onFollowedUserImagesSuccess, onFailed);
					break;
				case GalleryType.MOST_LOVED:
					amfBridge.getMostLovedImages(index, amount, onMostLovedSuccess, onFailed);
					break;
				case GalleryType.MOST_RECENT:
					amfBridge.getMostRecentPaintings(index, amount, onMostRecentSuccess, onFailed);
					break;
			}

			_index = index;
		}

		public function fetchPainting(paintingID : int) : void
		{
		}

		private function onUserImagesSuccess(data : Object) : void
		{
			translateImages(GalleryType.YOURS, data)
		}

		private function onFollowedUserImagesSuccess(data : Object) : void
		{
			translateImages(GalleryType.FOLLOWING, data);
		}

		private function onMostLovedSuccess(data : Object) : void
		{
			translateImages(GalleryType.MOST_LOVED, data);
		}

		private function onMostRecentSuccess(data : Object) : void
		{
			translateImages(GalleryType.MOST_RECENT, data);
		}

		private function onFailed(data : Object) : void
		{
			notifyGalleryImagesFailedSignal.dispatch(AMFErrorCode.CALL_FAILED);
		}

		private function translateImages(type : uint, data : Object) : void
		{
			if (data["status_code"] != 1) {
				notifyGalleryImagesError(data["status_code"]);
				return;
			}

			var array : Array = data["response"].items;
			var collection : GalleryImageCollection = new GalleryImageCollection();
			collection.numTotalPaintings = data["response"].numAvailable;
			collection.type = type;
			collection.index = _index;
			var len : int = array.length;
			for (var i : int = 0; i < len; ++i) {
				var obj : Object = array[i];
				var vo : FileGalleryImageProxy = new FileGalleryImageProxy();
				vo.id = obj["id"];
				vo.title = obj["title"];
				vo.fullsizeFilename = obj["url_image"];
				vo.lowResThumbnailFilename = obj["url_thumb50"];
				vo.highResThumbnailFilename = obj["url_thumb200"];
				vo.userName = obj["firstname"] + " " + obj["lastname"];
				vo.numLikes = obj["num_favorite"];
				vo.numComments = obj["num_comments"];
				vo.paintingMode = obj["is_photo_painting"] == 1? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE;
				collection.images.push(vo);
			}

			notifyGalleryImagesFetchedSignal.dispatch(collection);
		}

		private function notifyGalleryImagesError(statusCode : int) : void
		{
			notifyGalleryImagesFailedSignal.dispatch(statusCode);
		}

		public function addComment(paintingID : int, text : String) : void
		{
			amfBridge.addCommentToPainting(userProxy.sessionID, paintingID, text, onAddCommentSuccess, onAddCommentFailed);
		}

		public function favorite(paintingID : int) : void
		{
			amfBridge.favoritePainting(userProxy.sessionID, paintingID, onAddCommentSuccess, onAddCommentFailed);
		}

		private function onAddCommentSuccess() : void
		{
			notifyGalleryServiceCallSucceededSignal.dispatch();
		}

		private function onAddCommentFailed(statusCode : int) : void
		{
			notifyGalleryServiceCallFailedSignal.dispatch(statusCode);
		}
	}
}
