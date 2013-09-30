package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;
	import net.psykosoft.psykopaint2.core.views.components.button.LinkButton;

	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInputValidationUtil;

	import org.osflash.signals.Signal;

	public class LoginSubView extends Sprite
	{
		// Declared in Flash.
		public var emailInput:PsykoInput;
		public var passwordInput:PsykoInput;
		public var loginBtn:FoldButton;
		public var forgotButton:LinkButton;
		public var messages:TextField;

		public var viewWantsToLogInSignal:Signal;
		public var forgotBtnClickedSignal:Signal;

		private var _msgTimer:Timer;
		private var _satelliteMessages:Vector.<LoginMessageLabel>;

		public function LoginSubView() {
			super();

			viewWantsToLogInSignal = new Signal();
			forgotBtnClickedSignal = new Signal();

			loginBtn.labelText = "login";

			emailInput.defaultText = "email";
			passwordInput.defaultText = "password";
			forgotButton.labelText = "Forgot your password?";

			messages.visible = false;
			messages.mouseEnabled = messages.selectable = false;

			passwordInput.behavesAsPassword( true );

			_msgTimer = new Timer( 4000, 1 );
			_msgTimer.addEventListener( TimerEvent.TIMER, onMsgTimer );

			emailInput.enterPressedSignal.add( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.add( onPasswordInputEnterPressed );

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClick );
			forgotButton.addEventListener( MouseEvent.CLICK, onForgotBtnClick );

			_satelliteMessages = new Vector.<LoginMessageLabel>();
		}

		public function dispose():void {

			loginBtn.removeEventListener( MouseEvent.CLICK, onLoginBtnClick );
			forgotButton.removeEventListener( MouseEvent.CLICK, onForgotBtnClick );

			emailInput.enterPressedSignal.remove( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.remove( onPasswordInputEnterPressed );

			_msgTimer.removeEventListener( TimerEvent.TIMER, onMsgTimer );
			_msgTimer = null;

			emailInput.dispose();
			passwordInput.dispose();
			loginBtn.dispose();
			forgotButton.dispose();

			clearAllSatelliteMessages();
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function displayCenterMessage( msg:String ):void {
			messages.htmlText = msg;
			messages.width = messages.textWidth * 1.1;
			messages.x = 500 - messages.width / 2;
			messages.visible = true;
			_msgTimer.reset();
			_msgTimer.start();
		}

		public function displaySatelliteMessage( targetSource:Sprite, msg:String ):void {
			// TODO
		}

		public function clearAllSatelliteMessages():void {
			// TODO
		}

		public function rejectEmail():void {
			emailInput.showRedHighlight();
		}

		public function rejectPassword():void {
			passwordInput.showRedHighlight();
		}

		// -----------------------
		// Log in stuff.
		// -----------------------

		private function login():void {
			if( !validateEmailFormat() ) return;
			if( !validatePasswordFormat() ) return;
			viewWantsToLogInSignal.dispatch( emailInput.text, passwordInput.text );
		}

		private function forgot():void {
			if( !validateEmailFormat() ) return;
			forgotBtnClickedSignal.dispatch();
		}

		private function validateEmailFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateEmailFormat( emailInput );
			if( valid == 1 ) displayCenterMessage( LoginCopy.NO_EMAIL );
			if( valid == 2 ) displayCenterMessage( LoginCopy.EMAIL_INVALID );
			return valid == 0;
		}

		private function validatePasswordFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validatePasswordFormat( passwordInput );
			if( valid == 1 ) displayCenterMessage( LoginCopy.NO_PASSWORD );
			return valid == 0;
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onMsgTimer( event:TimerEvent ):void {
			messages.visible = false;
		}

		private function onForgotBtnClick( event:MouseEvent ):void {
			forgot();
		}

		private function onPasswordInputEnterPressed():void {
			login();
		}

		private function onEmailInputEnterPressed():void {
			passwordInput.focusIn( true );
		}

		private function onLoginBtnClick( event:MouseEvent ):void {
			login();
		}
	}
}
