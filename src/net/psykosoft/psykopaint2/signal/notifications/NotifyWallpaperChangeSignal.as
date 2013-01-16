package net.psykosoft.psykopaint2.signal.notifications
{

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;

	import org.osflash.signals.Signal;

	public class NotifyWallpaperChangeSignal extends Signal
	{
		public function NotifyWallpaperChangeSignal() {
			super( PackagedImageVO );
		}
	}
}
