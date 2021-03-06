package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class PsykoLabel extends Sprite
	{
		protected var _textfield:TextField;

		public function PsykoLabel() {
			super();
		}

		protected function setTextfield( textfield:TextField ):void {
			_textfield = textfield;
			_textfield.mouseEnabled = false;
			_textfield.selectable = false;
		}

		public function set text( value:String ):void {
			_textfield.text = value.toUpperCase();
			validateDimensions();
		}

		public function get text():String {
			return _textfield.text;
		}

		protected function validateDimensions():void {
			enforceTextWidth();
			_textfield.x = -_textfield.width / 2;
		}

		protected function  enforceTextWidth():void {
			_textfield.width = _textfield.textWidth + 10;
			_textfield.height = 1.25 * _textfield.textHeight;
		}
	}
}
