package net.psykosoft.psykopaint2.core.model
{
	public class UserPaintSettingsModel
	{
		private var _colorPalettes:Array;
		private var _currentColor:uint;
		
		public function UserPaintSettingsModel()
		{
			setDefaultValues();
		}
		
		private function setDefaultValues():void
		{
			_colorPalettes = [[0x0b0b0b,0x062750,0x04396c,0x01315a,0x00353b,0x026d01,
							   0x452204,0x7a1023,0xa91606,0xd94300,0xbd9c01,0xdedddb]];
			
		}
		
		public function set colorPalettes( value:Array ):void
		{
			_colorPalettes = value;
		}
		
		public function get colorPalettes():Array
		{
			return _colorPalettes;
		}
		
		public function set currentColor( value:uint ):void
		{
			_currentColor = value;
		}
		
		public function get currentColor():uint
		{
			return _currentColor;
		}
	}
}