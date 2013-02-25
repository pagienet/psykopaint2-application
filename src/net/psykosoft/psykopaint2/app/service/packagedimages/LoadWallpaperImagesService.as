package net.psykosoft.psykopaint2.app.service.packagedimages
{

	import net.psykosoft.psykopaint2.app.model.packagedimages.WallpapersModel;
	import net.psykosoft.psykopaint2.app.model.packagedimages.vo.PackagedImageVO;

	public class LoadWallpaperImagesService extends LoadPackagedImagesServiceBase
	{
		[Inject]
		public var wallpapersModel:WallpapersModel;

		public function LoadWallpaperImagesService() {
			FOLDER_PATH = "assets-packaged/wallpaper-images/";
			DUPLICATE_COUNT = 20;
			super();
		}

		override protected function reportImages( images:Vector.<PackagedImageVO> ):void {
			wallpapersModel.images = images;
		}
	}
}
