package net.psykosoft.psykopaint2.app.signal.notifications
{

	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyWallpaperChangeSignal extends Signal
	{
		public function NotifyWallpaperChangeSignal() {
			super( BitmapData );
		}
	}
}
