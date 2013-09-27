package net.psykosoft.psykopaint2.book.commands
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageRequestVO;
	import net.psykosoft.psykopaint2.core.models.GalleryService;

	public class FetchGalleryImagesCommand
	{
		[Inject]
		public var requestVO : GalleryImageRequestVO;

		[Inject]
		public var galleryImageService : GalleryService;

		public function execute() : void
		{
			trace (this, "execute()");
			galleryImageService.fetchImages(requestVO.galleryType, requestVO.index, requestVO.amount);
		}
	}
}
