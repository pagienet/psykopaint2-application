package net.psykosoft.psykopaint2.app.signal.notifications
{

	import net.psykosoft.psykopaint2.app.model.packagedimages.vo.PackagedImageVO;

	import org.osflash.signals.Signal;

	public class NotifyWallpaperImagesUpdatedSignal extends Signal
	{
		public function NotifyWallpaperImagesUpdatedSignal() {
			super( Vector.<PackagedImageVO> );
		}
	}
}
