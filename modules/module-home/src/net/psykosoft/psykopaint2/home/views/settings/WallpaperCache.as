package net.psykosoft.psykopaint2.home.views.settings
{
	public class WallpaperCache  {

		static private var _lastSelectedWallpaper:String = "default";

		static public function setLastSelectedWallpaper( value:String ):void {
			if( _lastSelectedWallpaper == value ) return;
			_lastSelectedWallpaper = value;
		}

		static public function getLastSelectedWallpaper():String {
			return _lastSelectedWallpaper;
		}
	}
}
