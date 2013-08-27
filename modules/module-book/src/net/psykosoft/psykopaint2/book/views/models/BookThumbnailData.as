package net.psykosoft.psykopaint2.book.views.models
{
	import net.psykosoft.psykopaint2.book.model.SourceImageVO;

	public class BookThumbnailData
	{
		public var imageVO : SourceImageVO;
		public var index : uint;
		public var pageIndex : uint;
		public var inPageIndex : uint;

		public function BookThumbnailData(imageVO : SourceImageVO, index : uint, pageIndex : uint, inPageIndex : uint)
		{
			this.imageVO = imageVO;
			this.index = index;
			this.pageIndex = pageIndex;
			this.inPageIndex = inPageIndex;
		}
	}
}
