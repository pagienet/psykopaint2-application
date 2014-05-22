package net.psykosoft.psykopaint2.core.models
{

	import flash.net.SharedObject;

	public class CanvasSurfaceSettingsModel
	{
		private var _surfaceID:int = 0;	// part of the surface filename (see core_packaged/images/surfaces/canvas_normal_specular_<id>_<size>.png)
		private var _localCache:SharedObject;

		public function CanvasSurfaceSettingsModel()
		{
			super();

			_localCache = SharedObject.getLocal("com.psykopaint.localData");

			if (_localCache.data["surfaceID"])
				_surfaceID = _localCache.data["surfaceID"];
			else
				_localCache.data["surfaceID"] = _surfaceID;
				_localCache.flush();
		}

		public function get surfaceID():int
		{
			return _surfaceID;
		}

		public function set surfaceID(value:int):void
		{
			_localCache.data["surfaceID"] = _surfaceID = value;
			_localCache.flush();
		}
	}
}
