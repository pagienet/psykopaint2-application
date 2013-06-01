package net.psykosoft.psykopaint2.paint.views.brush
{

	public class BrushParameterCache
	{
		static private var _lastSelectedBrush:String = "";
		static private var _lastSelectedParameter:String = "";

		static public function setLastSelectedBrush( value:String ):void {
			if( _lastSelectedBrush == value ) return;
			_lastSelectedBrush = value;
			_lastSelectedParameter = "";
		}

		static public function getLastSelectedParameter():String {
			return _lastSelectedParameter;
		}

		static public function setLastSelectedParameter( value:String ):void {
			_lastSelectedParameter = value;
		}
	}
}
