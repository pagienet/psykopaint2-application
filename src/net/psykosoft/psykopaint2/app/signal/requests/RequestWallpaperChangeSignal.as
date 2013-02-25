package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	public class RequestWallpaperChangeSignal extends Signal
	{
		public function RequestWallpaperChangeSignal() {
			super( String ); // Image id.
		}
	}
}
