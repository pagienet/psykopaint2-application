package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class LoginPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var selectLoginSubView:SelectLoginSubView;
		public var loginSubView:LoginSubView;
		public var signupSubView:SignupSubView;

		public var popUpWantsToCloseSignal:Signal;
		public var popUpWantsToLogInSignal:Signal;
		public var popUpRequestsForgottenPassword:Signal;

		public function LoginPopUpView() {
			super();

			popUpWantsToCloseSignal = new Signal();
			popUpWantsToLogInSignal = new Signal();
			popUpRequestsForgottenPassword = new Signal();

			loginSubView.visible = false;
			signupSubView.visible = false;
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClick );

			selectLoginSubView.loginClickedSignal.add( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.add( onSelectLoginSubViewSignupBtnClicked );

			loginSubView.viewWantsToLogInSignal.add( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.add( onLoginViewForgotButtonClicked );

			layout();
		}

		override protected function onDisabled():void {

			_blocker.removeEventListener( MouseEvent.CLICK, onBlockerClick );

			selectLoginSubView.loginClickedSignal.remove( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.remove( onSelectLoginSubViewSignupBtnClicked );

			loginSubView.viewWantsToLogInSignal.remove( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.remove( onLoginViewForgotButtonClicked );

			selectLoginSubView.dispose();
			loginSubView.dispose();
			signupSubView.dispose();

			super.onDisabled();
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onLoginViewForgotButtonClicked():void {
			popUpRequestsForgottenPassword.dispatch();
		}

		private function onLoginViewWantsToLogIn( email:String, password:String ):void {
			popUpWantsToLogInSignal.dispatch( email, password );
		}

		private function onSelectLoginSubViewSignupBtnClicked():void {
			selectLoginSubView.visible = false;
			signupSubView.visible = true;
		}

		private function onSelectLoginSubViewLoginBtnClicked():void {
			selectLoginSubView.visible = false;
			loginSubView.visible = true;
		}

		private function onBlockerClick( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}
	}
}
