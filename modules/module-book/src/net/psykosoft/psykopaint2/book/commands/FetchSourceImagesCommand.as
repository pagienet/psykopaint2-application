package net.psykosoft.psykopaint2.book.commands
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.model.SourceImageRequestVO;
	import net.psykosoft.psykopaint2.book.services.CameraRollService;
	import net.psykosoft.psykopaint2.book.services.SourceImageService;
	import net.psykosoft.psykopaint2.book.services.SampleImageService;

	public class FetchSourceImagesCommand
	{
		[Inject]
		public var requestVO : SourceImageRequestVO;

		[Inject]
		public var cameraRollService : CameraRollService;

		[Inject]
		public var sampleImageService : SampleImageService;

		public function execute() : void
		{
			var service : SourceImageService = getService();
			service.fetchImages(requestVO.index, requestVO.amount);
		}

		private function getService() : SourceImageService
		{
			var service : SourceImageService;

			switch (requestVO.bookImageSource) {
				case BookImageSource.CAMERAROLL_IMAGES:
					service = cameraRollService;
					break;
				case BookImageSource.SAMPLE_IMAGES:
					service = sampleImageService;
					break;
			}
			return service;
		}
	}
}
