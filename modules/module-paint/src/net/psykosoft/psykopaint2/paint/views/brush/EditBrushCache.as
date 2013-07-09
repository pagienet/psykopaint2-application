package net.psykosoft.psykopaint2.paint.views.brush
{
	public class EditBrushCache
	{
		static private var _lastSelectedBrush:String = "";
		static private var _lastSelectedParameter:Object = {};

		static public var lastScrollerPosition:Number = 372; //TODO: harcode works, might want to do it cleaner.

		static public function setLastSelectedBrush( value:String ):void {
			if( _lastSelectedBrush == value ) return;
			_lastSelectedBrush = value;
		}

		static public function getLastSelectedParameter( brushID:String ):String {
			return _lastSelectedParameter[brushID] || "";
		}

		static public function setLastSelectedParameter( value:String, brushID:String ):void {
			_lastSelectedParameter[brushID] = value;
		}
	}
}
