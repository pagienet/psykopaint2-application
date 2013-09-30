package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;

	public class GalleryImageProxy
	{
		public var id : int;
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

		public function loadFullsized(onComplete : Function, onError : Function) : void
		{
			throw new AbstractMethodError();
		}
	}
}
