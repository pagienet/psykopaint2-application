package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class LoginMessageLabel extends Sprite
	{
		// Declared in Flash.
		public var tf:TextField;

		public function LoginMessageLabel() {
			super();
		}

		public function set labelText( htmlText:String ):void {
			tf.htmlText = htmlText;
		}
	}
}
