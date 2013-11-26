package net.psykosoft.psykopaint2.book.views.models
{
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.book.views.models.BookData;

	public class BookThumbnailData extends BookData
	{
		public var imageVO : SourceImageProxy;

		public function BookThumbnailData(imageVO : SourceImageProxy, index : uint, pageIndex : uint, inPageIndex : uint)
		{
			super(index, pageIndex, inPageIndex);
			this.imageVO = imageVO;
		}
	}
}
