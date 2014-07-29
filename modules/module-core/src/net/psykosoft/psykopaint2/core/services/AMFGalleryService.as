package net.psykosoft.psykopaint2.core.services
{

import flash.utils.describeType;

import net.psykosoft.psykopaint2.core.models.*;

	public class AMFGalleryService implements GalleryService
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var userProxy : LoggedInUserProxy;

		private var _targetUserID:int;

		public function AMFGalleryService()
		{
		}

		// used for views to set the user ID that should be used for subsequent user painting requests
		// dirty, but the navigation system doesn't allow us to pass along optional props like these properly
		public function get targetUserID():int
		{
			return _targetUserID;
		}

		public function set targetUserID(value:int):void
		{
			_targetUserID = value;
		}

		public function fetchImages(source : int, index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			switch (source) {
				case GalleryType.YOURS:
					getLoggedInUserImages(index, amount, onSuccess, onFailure);
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
				case GalleryType.USER:
					getUserImages(index, amount, onSuccess, onFailure);
			}
		}

		private function getMostRecentPaintings(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) : void { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function(data : Object) : void
			{
				translateImages(GalleryType.MOST_RECENT, data, index, onSuccess, onFailure);
			}
			amfBridge.getMostRecentPaintings(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getMostLovedImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) : void { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function(data : Object) : void
			{
				translateImages(GalleryType.MOST_LOVED, data, index, onSuccess, onFailure);
			}
			amfBridge.getMostLovedImages(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getFollowedUserImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) : void { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function (data : Object) : void
			{
				translateImages(GalleryType.FOLLOWING, data, index, onSuccess, onFailure);
			};
			amfBridge.getFollowedUserImages(userProxy.sessionID, index, amount, callback, failFunction);
		}

		private function getLoggedInUserImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) : void { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function (data : Object) : void
			{
				translateImages(GalleryType.YOURS, data, index, onSuccess, onFailure);
			}
			amfBridge.getUserImages(userProxy.sessionID, userProxy.userID, index, amount, callback, failFunction);
		}

		private function getUserImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void
		{
			var failFunction : Function = function(data : Object) : void { onFailure(AMFErrorCode.CALL_FAILED); }
			var callback : Function = function (data : Object) : void
			{
				translateImages(GalleryType.USER, data, index, onSuccess, onFailure);
			}
			amfBridge.getUserImages(userProxy.sessionID, _targetUserID, index, amount, callback, failFunction);
		}

		private function translateImages(type : uint, data : Object, index : int, onSuccess : Function, onFailure : Function) : void
		{
			if (data["status_code"] != 1) {
				trace("gallery AMF error with status_code " + data["status_code"]);
				onFailure(data["status_code"]);
				return;
			}

			var array : Array = data["response"].items;
			var collection : GalleryImageCollection = new GalleryImageCollection();
			collection.numTotalPaintings = data["response"].num_available;
			collection.type = type;
			collection.index = index;
			var len : int = array.length;
			for (var i : int = 0; i < len; ++i) {
				var obj : Object = array[i];
//				for(var prop:* in obj) trace("property: " + prop + ", value: " + obj[prop]); // Uncomment to see dynamic props of incoming object
				var vo : FileGalleryImageProxy = new FileGalleryImageProxy();
				vo.paintingMode = obj["is_photo_painting"] == "1" ? PaintMode.PHOTO_MODE : PaintMode.COLOR_MODE;
				vo.id = obj["id"];
				vo.index = index + i;
				vo.collectionType = type;
				vo.title = obj["title"];
				vo.normalSpecularMapURL = obj["normalmapdata_url"];
				vo.colorMapURL = obj["colordata_url"];
				vo.sourceThumbnailURL = obj["source_thumbnail_url"];
				vo.tinySizeURL = obj["composite_tiny_url"];
				vo.smallSizeURL = obj["composite_small_url"];
				vo.mediumSizeURL = obj["composite_medium_url"];
				vo.fullsizeURL = obj["composite_fullsize_url"];
				vo.userName = obj["firstname"] + " " + obj["lastname"];
				vo.numLikes = obj["num_favorite"];
				vo.numComments = obj["num_comments"];
				vo.userID = obj["user_id"];
				vo.userThumbnailURL = obj["user_thumbnail_url"];
				vo.isFavorited = obj.hasOwnProperty("is_favorited")? obj["is_favorited"] : false;
				collection.images.push(vo);
			}

			onSuccess(collection);
		}

		public function addComment(paintingID : int, text : String, onSuccess : Function, onFailure : Function) : void
		{
			trace(this+"paintingID:"+paintingID+" text:"+text);
			amfBridge.addCommentToPainting(userProxy.sessionID, paintingID, text, emptyCallBack(onSuccess), onFailure);
		}

		public function favorite(paintingID : int, onSuccess : Function, onFailure : Function) : void
		{
			trace(this+"favorite "+paintingID);
			amfBridge.favoritePainting(userProxy.sessionID, paintingID, emptyCallBack(onSuccess), onFailure);
		}
		
		public function removePainting(paintingID : int, onSuccess : Function, onFailure : Function) : void
		{
			trace(this+"removePainting "+paintingID);
			amfBridge.removePainting(userProxy.sessionID, paintingID, emptyCallBack(onSuccess), onFailure);
		}

		public function unfavorite(paintingID : int, onSuccess : Function, onFailure : Function) : void
		{
			trace(this+"unfavorite "+paintingID);
			amfBridge.unfavoritePainting(userProxy.sessionID, paintingID, emptyCallBack(onSuccess), onFailure);
		}

		private function emptyCallBack(callback : Function) : Function
		{
			return function(data : Object) : void { callback(); }
		}
	}
}
