package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class LoginPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var loginBtn:FoldButton;
		public var signupBtn:FoldButton;
		public var emailInput:PsykoInput;
		public var passwordInput:PsykoInput;

		public var popUpWantsToCloseSignal:Signal;
		public var popUpWantsToLogInSignal:Signal;

		public function LoginPopUpView() {
			super();
			popUpWantsToCloseSignal = new Signal();
			popUpWantsToLogInSignal = new Signal();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClick );

			loginBtn.labelText = "login";
			signupBtn.labelText = "sign up";

			emailInput.defaultText = "email";
			passwordInput.defaultText = "password";

			passwordInput.behavesAsPassword( true );

			emailInput.enterPressedSignal.add( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.add( onPasswordInputEnterPressed );

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClick );

			layout();
		}

		override protected function onDisabled():void {

			_blocker.removeEventListener( MouseEvent.CLICK, onBlockerClick );
			loginBtn.removeEventListener( MouseEvent.CLICK, onLoginBtnClick );

			emailInput.enterPressedSignal.remove( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.remove( onPasswordInputEnterPressed );

			loginBtn.dispose();
			signupBtn.dispose();

			emailInput.dispose();
			passwordInput.dispose();

			super.onDisabled();
		}

		// -----------------------
		// Log in stuff.
		// -----------------------

		private function login():void {

			trace( this, "logging in..." );

			// Validate email address format.
			var emailRegex:RegExp = /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			var isEmailValid:Boolean = emailInput.text.length > 0 && emailRegex.test( emailInput.text );
			if( isEmailValid ) emailInput.showBlueHighlight();
			else {
				trace( this, "invalid email format" );
				emailInput.showRedHighlight();
				return;
			}

			// Validate password format.
			var isPasswordValid:Boolean = passwordInput.text.length > 0;
			if( isPasswordValid ) passwordInput.showBlueHighlight();
			else {
				trace( this, "invalid password format" );
				passwordInput.showRedHighlight();
				return;
			}

			// Request log in to mediator.
			popUpWantsToLogInSignal.dispatch( emailInput.text, passwordInput.text );
		}

		public function rejectEmail():void {
			emailInput.showRedHighlight();
		}

		public function rejectPassword():void {
			passwordInput.showRedHighlight();
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onPasswordInputEnterPressed():void {
			login();
		}

		private function onEmailInputEnterPressed():void {
			passwordInput.focusIn( true );
		}

		private function onLoginBtnClick( event:MouseEvent ):void {
			login();
		}

		private function onBlockerClick( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}
	}
}
