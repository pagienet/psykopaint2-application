package net.psykosoft.psykopaint2.home.signals
{

	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class RequestWallpaperChangeSignal extends Signal
	{
		public function RequestWallpaperChangeSignal() {
			super( ByteArray ); // Atf file.
		}
	}
}