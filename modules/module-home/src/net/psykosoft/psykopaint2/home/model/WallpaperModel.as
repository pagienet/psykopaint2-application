package net.psykosoft.psykopaint2.home.model
{

	import flash.net.SharedObject;
	
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	public class WallpaperModel
	{
		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _wallpaperId:String = "2"; // Part of the file name in home-packaged-desktop/away3d/wallpapers/fullsize, eg. "white" in white-desktop.atf.
		private var _localCache : SharedObject;
		
		public function WallpaperModel() {
			super();
			_localCache = SharedObject.getLocal("com.psykopaint.localData");
			if (_localCache.data["wallpaperId"] )
			{
				_wallpaperId = _localCache.data["wallpaperId"];
			} else {
				_localCache.data["wallpaperId"] = _wallpaperId;
				_localCache.flush();
			}
		}

		public function get wallpaperId():String {
			return _wallpaperId;
		}

		public function set wallpaperId( value:String ):void {
			_localCache.data["wallpaperId"] = _wallpaperId = value;
			_localCache.flush();
			requestWallpaperChangeSignal.dispatch( value );
		}
	}
}
