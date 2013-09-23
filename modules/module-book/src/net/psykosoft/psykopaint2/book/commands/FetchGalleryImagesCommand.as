package net.psykosoft.psykopaint2.book.commands
{
	import net.psykosoft.psykopaint2.book.model.GalleryImageRequestVO;
	import net.psykosoft.psykopaint2.book.services.GalleryImageService;

	public class FetchGalleryImagesCommand
	{
		[Inject]
		public var requestVO : GalleryImageRequestVO;

		[Inject]
		public var galleryImageService : GalleryImageService;

		public function execute() : void
		{
			trace (this, "execute()");
			galleryImageService.fetchImages(requestVO.galleryType, requestVO.index, requestVO.amount);
		}
	}
}
