package net.psykosoft.psykopaint2.book.views.book.layout
{
	import flash.geom.Rectangle;

	// Class keeps track of loaded data to composite images possibly loaded in two tastes: low and high res
 	public class InsertRef
 	{
 		public var name:String;
 		public var rotation:Number;
 		public var hasHighres:Boolean;
 		public var rectangle:Rectangle;
 		public var pageIndex:uint;
		public var inPageIndex:uint;
 	}
 }