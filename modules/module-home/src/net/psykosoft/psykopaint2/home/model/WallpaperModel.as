package net.psykosoft.psykopaint2.home.model
{

	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	public class WallpaperModel
	{
		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _wallpaperId:String = "stucco"; // Part of the file name in home-packaged-desktop/away3d/wallpapers/fullsize, eg. "white" in white-desktop.atf.

		public function WallpaperModel() {
			super();
		}

		public function get wallpaperId():String {
			return _wallpaperId;
		}

		public function set wallpaperId( value:String ):void {
			_wallpaperId = value;
			requestWallpaperChangeSignal.dispatch( value );
		}
	}
}
