package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;

	public class GalleryImageProxy
	{
		public var id : int;
		public var index : int;				// the index in the gallery order
		public var collectionType : uint;   // the gallery it belongs to
		public var userName : String;
		public var numLikes : uint;
		public var title : String;
		public var numComments : uint;
		public var paintingMode : int;	// any of PaintMode 1: painting 0: photo painting
		public var isFavorited : Boolean;
		public var userThumbnailURL : String;
		public var userID : int;

		public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			throw new AbstractMethodError();
		}

		public function loadFullSizedComposite(onComplete : Function, onError : Function) : void
		{
			throw new AbstractMethodError();
		}

		// onSurfaceColorDataComplete is optional
		public function loadSurfaceData(onComplete:Function, onError:Function, onSurfaceColorDataComplete:Function = null) :void
		{
			throw new AbstractMethodError();
		}

		public function cancelLoading() : void
		{

		}

		public function clone():GalleryImageProxy
		{
			throw new AbstractMethodError();
		}

		protected function copyTo(clone:GalleryImageProxy):void
		{
			clone.id = id;
			clone.index = index;
			clone.collectionType = collectionType;
			clone.userName = userName;
			clone.numLikes = numLikes;
			clone.title = title;
			clone.numComments = numComments;
			clone.paintingMode = paintingMode;
			clone.isFavorited = isFavorited;
			clone.userID = userID;
			clone.userThumbnailURL = userThumbnailURL;
		}
	}
}
