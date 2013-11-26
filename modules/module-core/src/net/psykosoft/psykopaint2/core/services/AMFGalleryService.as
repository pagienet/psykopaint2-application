package net.psykosoft.psykopaint2.core.services
{
	import net.psykosoft.psykopaint2.core.models.*;
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;

	public class AMFGalleryService implements GalleryService
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var userProxy : LoggedInUserProxy;

		public function AMFGalleryService()
		{
		}

		public function fetchImages(source : int, index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			switch (source) {
				case GalleryType.YOURS:
					getUserImages(index, amount, onSuccess, onFailure);
					break;
				case GalleryType.FOLLOWING:
					getFollowedUserImages(index, amount, onSuccess, onFailure);
					break;
				case GalleryType.MOST_LOVED:
					getMostLovedImages(index, amount, onSuccess, onFailure);
					break;
				case GalleryType.MOST_RECENT:
					getMostRecentPaintings(index, amount, onSuccess, onFailure);
					break;
			}
		}

		private function getMostRecentPaintings(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function(data : Object)
			{
				translateImages(GalleryType.MOST_RECENT, data, index, onSuccess, onFailure);
			}
			amfBridge.getMostRecentPaintings(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getMostLovedImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function(data : Object)
			{
				translateImages(GalleryType.MOST_LOVED, data, index, onSuccess, onFailure);
			}
			amfBridge.getMostLovedImages(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getFollowedUserImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function (data : Object)
			{
				translateImages(GalleryType.FOLLOWING, data, index, onSuccess, onFailure);
			};
			amfBridge.getFollowedUserImages(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getUserImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function (data : Object)
			{
				translateImages(GalleryType.YOURS, data, index, onSuccess, onFailure);
			}
			amfBridge.getUserImages(userProxy.userID, index, amount, callback, failFunction);
		}

		private function translateImages(type : uint, data : Object, index : int, onSuccess : Function, onFailure : Function) : void
		{
			if (data["status_code"] != 1) {
				onFailure(data["status_code"]);
				return;
			}

			var array : Array = data["response"].items;
			var collection : GalleryImageCollection = new GalleryImageCollection();
			collection.numTotalPaintings = data["response"].numAvailable;
			collection.type = type;
			collection.index = index;
			var len : int = array.length;
			for (var i : int = 0; i < len; ++i) {
				var obj : Object = array[i];
				var vo : FileGalleryImageProxy = new FileGalleryImageProxy();
				vo.id = obj["id"];
				vo.title = obj["title"];
				vo.normalSpecularMapURL = obj["normalmapdata_url"];
				vo.colorMapURL = obj["colordata_url"];
				vo.sourceThumbnailURL = obj["source_thumbnail_url"];
				vo.thumbnailFilename = obj["composite_thumbnail_url"];
				vo.compositeFilename = obj["composite_url"];
				vo.userName = obj["firstname"] + " " + obj["lastname"];
				vo.numLikes = obj["num_favorite"];
				vo.numComments = obj["num_comments"];
				vo.userID = obj["user_id"];
				vo.isFavorited = obj.hasOwnProperty("is_favorited")? obj["is_favorited"] : false;
				vo.paintingMode = obj["is_photo_painting"] == 1? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE;
				collection.images.push(vo);
			}

			onSuccess(collection);
		}

		public function addComment(paintingID : int, text : String, onSuccess : Function, onFailure : Function) : void
		{
			amfBridge.addCommentToPainting(userProxy.sessionID, paintingID, text, emptyCallBack(onSuccess), onFailure);
		}

		public function favorite(paintingID : int, onSuccess : Function, onFailure : Function) : void
		{
			amfBridge.favoritePainting(userProxy.sessionID, paintingID, emptyCallBack(onSuccess), onFailure);
		}

		private function emptyCallBack(callback : Function) : Function
		{
			return function(data : Object) { callback(); }
		}
	}
}
