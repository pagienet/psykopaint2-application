package net.psykosoft.psykopaint2.book.views.models
{
	public class BookData
	{
		public var index : uint;
		public var pageIndex : uint;
		public var inPageIndex : uint;

		public function BookData(index : uint, pageIndex : uint, inPageIndex : uint)
		{
			this.index = index;
			this.pageIndex = pageIndex;
			this.inPageIndex = inPageIndex;
		}
	}
}