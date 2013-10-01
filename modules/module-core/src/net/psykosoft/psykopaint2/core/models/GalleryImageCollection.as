package net.psykosoft.psykopaint2.core.models
{
	public class GalleryImageCollection
	{
		public var type : uint;	// any of GalleryType
		public var images : Vector.<GalleryImageProxy> = new Vector.<GalleryImageProxy>();
		public var index : int;
		public var numTotalPaintings : int;
	}
}
