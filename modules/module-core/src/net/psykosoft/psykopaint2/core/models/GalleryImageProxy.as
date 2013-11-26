package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	public class GalleryImageProxy
	{
		public var id : int;
		public var index : int;				// the index in the gallery order
		public var collectionType : uint;   // the gallery it belongs to
		public var userName : String;
		public var numLikes : uint;
		public var title : String;
		public var numComments : uint;
		public var paintingMode : String;	// any of PaintMode
		public var isFavorited : Boolean;
		public var userID : int;

		public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			throw new AbstractMethodError();
		}

		public function loadFullSizedComposite(onComplete : Function, onError : Function) : void
		{
			throw new AbstractMethodError();
		}

		public function loadSurfaceData(onComplete : Function, onError : Function) : void
		{
			throw new AbstractMethodError();
		}

		public function cancelLoading() : void
		{

		}
	}
}
