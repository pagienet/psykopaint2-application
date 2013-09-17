package net.psykosoft.psykopaint2.book.views.models
{
	import net.psykosoft.psykopaint2.book.model.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.views.models.BookData;

	public class BookGalleryData extends BookData
	{
		public var imageVO : GalleryImageProxy;

		public function BookGalleryData(imageVO : GalleryImageProxy, index : uint, pageIndex : uint, inPageIndex : uint)
		{
			super(index, pageIndex, inPageIndex);
			this.imageVO = imageVO;
		}
	}
}