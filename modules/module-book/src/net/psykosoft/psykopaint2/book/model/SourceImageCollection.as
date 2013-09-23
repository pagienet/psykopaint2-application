package net.psykosoft.psykopaint2.book.model
{
	public class SourceImageCollection
	{
		public var source : String;	// any of BookImageSource
		public var images : Vector.<SourceImageProxy> = new Vector.<SourceImageProxy>();
		public var index : int;
		public var numTotalImages : int;
	}
}
