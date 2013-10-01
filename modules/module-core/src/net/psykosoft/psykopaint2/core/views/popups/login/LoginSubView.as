package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.base.utils.misc.MathUtil;

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
		public var static1:Sprite;
		public var static2:Sprite;

		public var viewWantsToLogInSignal:Signal;
		public var forgotBtnClickedSignal:Signal;

		private var _satelliteMessages:Vector.<LoginMessageLabel>;

		public function LoginSubView() {
			super();

			viewWantsToLogInSignal = new Signal();
			forgotBtnClickedSignal = new Signal();

			loginBtn.labelText = "LOGIN";

			emailInput.defaultText = "email";
			passwordInput.defaultText = "password";
			forgotButton.labelText = "Forgot your password?";

			passwordInput.behavesAsPassword( true );

			emailInput.enterPressedSignal.add( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.add( onPasswordInputEnterPressed );

			loginBtn.addEventListener( MouseEvent.CLICK, onLoginBtnClick );
			forgotButton.addEventListener( MouseEvent.CLICK, onForgotBtnClick );
		}

		public function dispose():void {

			loginBtn.removeEventListener( MouseEvent.CLICK, onLoginBtnClick );
			forgotButton.removeEventListener( MouseEvent.CLICK, onForgotBtnClick );

			emailInput.enterPressedSignal.remove( onEmailInputEnterPressed );
			passwordInput.enterPressedSignal.remove( onPasswordInputEnterPressed );

			emailInput.dispose();
			passwordInput.dispose();
			loginBtn.dispose();
			forgotButton.dispose();

			clearAllSatelliteMessages();
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function displaySatelliteMessage( targetSource:Sprite, msg:String ):void {
			var label:LoginMessageLabel = new LoginMessageLabel();
			label.labelText = msg;
			label.x = targetSource.x + targetSource.width / 2 + 5;
			label.y = targetSource.y + MathUtil.rand( -10, 10 );
			label.rotation = MathUtil.rand( -10, 10 );
			addChild( label );
			if( !_satelliteMessages ) _satelliteMessages = new Vector.<LoginMessageLabel>();
			_satelliteMessages.push( label );
		}

		public function clearAllSatelliteMessages():void {
			static1.visible = false;
			static2.visible = false;
			if( !_satelliteMessages ) return;
			var label:LoginMessageLabel;
			var length:uint = _satelliteMessages.length;
			for(var i:uint; i < length; ++i) {
				label = _satelliteMessages[ i ];
				removeChild( label );
			}
			_satelliteMessages = null;
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
			clearAllSatelliteMessages();
			if( !validateEmailFormat() ) return;
			if( !validatePasswordFormat() ) return;
			viewWantsToLogInSignal.dispatch( emailInput.text, passwordInput.text );
		}

		private function forgot():void {
			clearAllSatelliteMessages();
			if( !validateEmailFormat() ) return;
			forgotBtnClickedSignal.dispatch();
		}

		private function validateEmailFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateEmailFormat( emailInput );
			if( valid == 1 ) displaySatelliteMessage( emailInput, LoginCopy.NO_EMAIL );
			if( valid == 2 ) displaySatelliteMessage( emailInput, LoginCopy.EMAIL_INVALID );
			return valid == 0;
		}

		private function validatePasswordFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validatePasswordFormat( passwordInput );
			if( valid == 1 ) displaySatelliteMessage( passwordInput, LoginCopy.NO_PASSWORD );
			return valid == 0;
		}

		// -----------------------
		// Event handlers.
		// -----------------------

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
