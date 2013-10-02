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
		public var backBtn:FoldButton;

		public var loginClickedSignal:Signal;
		public var signupClickedSignal:Signal;
		public var backBtnClickedSignal:Signal;

		public function SelectLoginSubView() {
			super();

			loginClickedSignal = new Signal();
			signupClickedSignal = new Signal();
			backBtnClickedSignal = new Signal();

			loginBtn.labelText = "LOGIN";
			signupBtn.labelText = "SIGN UP";
			backBtn.labelText = "BACK";

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClicked );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClicked );
			backBtn.addEventListener( MouseEvent.CLICK, onBackBtnClick );
		}

		public function dispose():void {

			loginBtn.dispose();
			signupBtn.dispose();
			backBtn.dispose();

			loginBtn.removeEventListener( MouseEvent.CLICK, onLoginBtnClicked );
			signupBtn.removeEventListener( MouseEvent.CLICK, onSignupBtnClicked );
			backBtn.removeEventListener( MouseEvent.CLICK, onBackBtnClick );
		}

		// -----------------------
		// Event listeners.
		// -----------------------

		private function onBackBtnClick( event:MouseEvent ):void {
			backBtnClickedSignal.dispatch();
		}

		private function onLoginBtnClicked( event:MouseEvent ):void {
			loginClickedSignal.dispatch();
		}

		private function onSignupBtnClicked( event:MouseEvent ):void {
			signupClickedSignal.dispatch();
		}
	}
}
