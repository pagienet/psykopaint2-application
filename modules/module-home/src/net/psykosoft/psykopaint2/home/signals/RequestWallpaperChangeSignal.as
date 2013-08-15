package net.psykosoft.psykopaint2.home.signals
{

	import org.osflash.signals.Signal;

	public class RequestWallpaperChangeSignal extends Signal
	{
		public function RequestWallpaperChangeSignal() {
			super( String ); // Part of the file name in home-packaged-desktop/away3d/wallpapers/fullsize, eg. "white" in white-desktop.atf.
		}
	}
}
