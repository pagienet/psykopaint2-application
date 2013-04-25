package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	import starling.textures.Texture;

	public class RequestWallpaperChangeSignal extends Signal
	{
		public function RequestWallpaperChangeSignal() {
			super( Texture );
		}
	}
}
