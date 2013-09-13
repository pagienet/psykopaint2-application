package net.psykosoft.psykopaint2.book.model
{
	public class GalleryImageRequestVO
	{
		public var galleryType : uint;
		public var index : int;
		public var amount : int;

		public function GalleryImageRequestVO(galleryType : uint, index : int, amount : int)
		{
			this.galleryType = galleryType;
			this.index = index;
			this.amount = amount;
		}
	}
}
