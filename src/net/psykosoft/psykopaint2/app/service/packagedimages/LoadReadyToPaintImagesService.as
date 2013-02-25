package net.psykosoft.psykopaint2.app.service.packagedimages
{

	import net.psykosoft.psykopaint2.app.model.packagedimages.SourceImagesModel;
	import net.psykosoft.psykopaint2.app.model.packagedimages.vo.PackagedImageVO;

	public class LoadReadyToPaintImagesService extends LoadPackagedImagesServiceBase
	{
		[Inject]
		public var sourceImagesModel:SourceImagesModel;

		public function LoadReadyToPaintImagesService() {
			FOLDER_PATH = "assets-packaged/source-images/";
			super();
		}

		override protected function reportImages( images:Vector.<PackagedImageVO> ):void {
			sourceImagesModel.images = images;
		}
	}
}