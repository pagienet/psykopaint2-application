package net.psykosoft.psykopaint2.paint.views.pick.surface {

	public class PickASurfaceCache  {

		static private var _lastSelectedSurface:String = "Canvas";

		static public function setLastSelectedSurface( value:String ):void {
			if( _lastSelectedSurface == value ) return;
			_lastSelectedSurface = value;
		}

		static public function getLastSelectedSurface():String {
			return _lastSelectedSurface;
		}
	}
}
