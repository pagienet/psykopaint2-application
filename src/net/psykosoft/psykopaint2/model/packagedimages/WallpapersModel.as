package net.psykosoft.psykopaint2.model.packagedimages
{

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperImagesUpdatedSignal;

	public class WallpapersModel extends PackagedImagesModelBase
	{
		[Inject]
		public var notifyWallpaperImagesUpdatedSignal:NotifyWallpaperImagesUpdatedSignal;

		override protected function reportUpdate( images:Vector.<PackagedImageVO> ):void {
			notifyWallpaperImagesUpdatedSignal.dispatch( images );
		}
	}
}
