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
			tf.selectable = tf.mouseEnabled = false;
			tf.multiline = true;
		}

		public function set labelText( htmlText:String ):void {
			tf.htmlText = htmlText;
			tf.width = tf.textWidth + 10;
			tf.height = 1.25 * tf.textHeight;
		}
	}
}
