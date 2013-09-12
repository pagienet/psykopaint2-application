package net.psykosoft.psykopaint2.book.model
{
	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;

	public class GalleryImageProxy
	{
		public var userName : String;
		public var numLikes : uint;
		public var numComments : uint;
		public var paintingMode : String;	// any of PaintMode

		public function loadThumbnail(onComplete : Function, onError : Function) : void
		{
			throw new AbstractMethodError();
		}
	}
}
