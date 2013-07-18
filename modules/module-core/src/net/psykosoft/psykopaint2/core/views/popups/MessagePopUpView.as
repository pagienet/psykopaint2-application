package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	public class MessagePopUpView extends PopUpViewBase
	{
		public function MessagePopUpView() {
			super();
		}

		private var _textField:TextField;

		override protected function onEnabled():void {
			super.onEnabled();

			_container.graphics.beginFill( 0xCCCCCC, 1.0 );
			_container.graphics.drawRect( 0, 0, 128, 64 );
			_container.graphics.endFill();

			_textField = new TextField();
			_textField.selectable = _textField.mouseEnabled = false;
			_textField.width = 128;
			_textField.height = 64;
			_container.addChild( _textField );

			layout();
		}

		public function updateMessage( newMessage:String ):void {
			_textField.text = newMessage;
		}
	}
}
