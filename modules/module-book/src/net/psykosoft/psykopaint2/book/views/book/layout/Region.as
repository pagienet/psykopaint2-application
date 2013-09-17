package net.psykosoft.psykopaint2.book.views.book.layout
{
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.book.views.models.BookData;

	//the region object to retrieve the correct image selected on mousedown

 	public class Region
 	{
 		public var UVRect:Rectangle;
 		public var data:BookData;
 		public var pageIndex:uint;
 	}
 }