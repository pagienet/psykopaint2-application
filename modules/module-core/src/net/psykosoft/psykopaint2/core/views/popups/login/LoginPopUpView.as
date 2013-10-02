package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
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
		public var popUpRequestsForgottenPasswordSignal:Signal;
		public var popUpWantsToRegisterSignal:Signal;

		public function LoginPopUpView() {
			super();

			popUpWantsToCloseSignal = new Signal();
			popUpWantsToLogInSignal = new Signal();
			popUpRequestsForgottenPasswordSignal = new Signal();
			popUpWantsToRegisterSignal = new Signal();

			loginSubView.visible = false;
			signupSubView.visible = false;
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClick );

			selectLoginSubView.loginClickedSignal.add( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.add( onSelectLoginSubViewSignupBtnClicked );
			selectLoginSubView.backBtnClickedSignal.add( onSelectLoginBackBtnClicked );

			loginSubView.viewWantsToLogInSignal.add( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.add( onLoginViewForgotButtonClicked );
			loginSubView.backBtnClickedSignal.add( onLoginWantsToGoBack );

			signupSubView.viewWantsToRegisterSignal.add( onSignupViewWantsToRegister );
			signupSubView.backBtnClickedSignal.add( onRegisterWantsToGoBack );

			layout();
		}

		override protected function onDisabled():void {

			_blocker.removeEventListener( MouseEvent.CLICK, onBlockerClick );

			selectLoginSubView.loginClickedSignal.remove( onSelectLoginSubViewLoginBtnClicked );
			selectLoginSubView.signupClickedSignal.remove( onSelectLoginSubViewSignupBtnClicked );
			selectLoginSubView.backBtnClickedSignal.remove( onSelectLoginBackBtnClicked );

			loginSubView.viewWantsToLogInSignal.remove( onLoginViewWantsToLogIn );
			loginSubView.forgotBtnClickedSignal.remove( onLoginViewForgotButtonClicked );
			loginSubView.backBtnClickedSignal.remove( onLoginWantsToGoBack );

			signupSubView.viewWantsToRegisterSignal.remove( onSignupViewWantsToRegister );
			signupSubView.backBtnClickedSignal.remove( onRegisterWantsToGoBack );

			selectLoginSubView.dispose();
			loginSubView.dispose();
			signupSubView.dispose();

			super.onDisabled();
		}

		// -----------------------
		// Private.
		// -----------------------

		private function returnToSelectScreen():void {
			selectLoginSubView.visible = true;
			signupSubView.visible = loginSubView.visible = false;
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onSelectLoginBackBtnClicked():void {
			popUpWantsToCloseSignal.dispatch();
		}

		private function onRegisterWantsToGoBack():void {
			returnToSelectScreen();
		}

		private function onLoginWantsToGoBack():void {
			returnToSelectScreen();
		}

		private function onSignupViewWantsToRegister( email:String, password:String, firstName:String, lastName:String, photoLarge:BitmapData, photoSmall:BitmapData ):void {
			popUpWantsToRegisterSignal.dispatch( email, password, firstName, lastName, photoLarge, photoSmall );
		}

		private function onLoginViewForgotButtonClicked():void {
			popUpRequestsForgottenPasswordSignal.dispatch();
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
