package net.psykosoft.psykopaint2.core.views.components.label
{

	import flash.display.Sprite;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.base.ui.components.BackgroundLabel;

	public class SbRightLabel extends BackgroundLabel
	{
		// Declared in Flash.
		public var textfield:TextField;
		public var background:Sprite;

		private var _textfieldSnapX:Number;

		public function SbRightLabel() {
			super();
			super.setBackground( background );
			super.setTextfield( textfield );
			_textfieldSnapX = textfield.x + textfield.width;
		}

		override protected function validateDimensions():void {
			enforceTextWidth();
			_textfield.x = _textfieldSnapX - _textfield.width;
			matchBackgroundWidthToText( 40 );
		}
	}
}
