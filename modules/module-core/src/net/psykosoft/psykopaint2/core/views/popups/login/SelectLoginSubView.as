package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;

	import org.osflash.signals.Signal;

	public class SelectLoginSubView extends Sprite
	{
		// Declared in Flash.
		public var loginBtn:FoldButton;
		public var signupBtn:FoldButton;

		public var loginClickedSignal:Signal;
		public var signupClickedSignal:Signal;

		public function SelectLoginSubView() {
			super();

			loginClickedSignal = new Signal();
			signupClickedSignal = new Signal();

			loginBtn.labelText = "LOGIN";
			signupBtn.labelText = "SIGN UP";

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClicked );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClicked );
		}

		public function dispose():void {

			loginBtn.dispose();
			signupBtn.dispose();

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClicked );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClicked );
		}

		// -----------------------
		// Event listeners.
		// -----------------------

		private function onLoginBtnClicked( event:MouseEvent ):void {
			loginClickedSignal.dispatch();
		}

		private function onSignupBtnClicked( event:MouseEvent ):void {
			signupClickedSignal.dispatch();
		}
	}
}
