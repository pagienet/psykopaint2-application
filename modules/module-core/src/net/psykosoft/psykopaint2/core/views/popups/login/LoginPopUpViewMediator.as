package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.UserRegistrationVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegisteredSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegistrationFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class LoginPopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:LoginPopUpView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var loggedInUserProxy:LoggedInUserProxy;

		[Inject]
		public var notifyUserLoggedInSignal : NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal : NotifyUserLogInFailedSignal;

		[Inject]
		public var notifyUserRegistrationFailedSignal : NotifyUserRegistrationFailedSignal;

		[Inject]
		public var notifyUserRegisteredSignal : NotifyUserRegisteredSignal;

		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From view.
			view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
			view.popUpWantsToLogInSignal.add( onPopUpWantsToLogIn );
			view.popUpRequestsForgottenPasswordSignal.add( onForgottenPassword );
			view.popUpWantsToRegisterSignal.add( onPopUpWantsToRegister );

			// From app.
			notifyUserLoggedInSignal.add( onLoginSuccess );
			notifyUserLogInFailedSignal.add( onLoginFailure );
			notifyUserRegisteredSignal.add( onRegisterSuccess );
			notifyUserRegistrationFailedSignal.add( onRegisterFailure );
		}

		override public function destroy():void {
			super.destroy();
			view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
			view.popUpWantsToLogInSignal.remove( onPopUpWantsToLogIn );
			notifyUserLoggedInSignal.remove( onLoginSuccess );
			notifyUserLogInFailedSignal.remove( onLoginFailure );
			notifyUserRegisteredSignal.remove( onRegisterSuccess );
			notifyUserRegistrationFailedSignal.remove( onRegisterFailure );
			view.popUpWantsToRegisterSignal.remove( onPopUpWantsToRegister );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onRegisterFailure( amfErrorCode:int ):void {
			trace( this, "register failed" );
			// TODO: give feedback about error
			view.signupSubView.rejectPassword();
		}

		private function onRegisterSuccess():void {
			trace( this, "registered" );
		}

		// the fail signal contains an int with a value from AMFErrorCode.as
		private function onLoginFailure( amfErrorCode:int ):void {
			trace( this, "login failed" );
			// TODO: give feedback about error
			view.loginSubView.rejectPassword();
		}

		private function onLoginSuccess():void {
			trace( this, "logged in" );
			view.loginSubView.displayCenterMessage( LoginCopy.WELCOME_BACK + loggedInUserProxy.firstName + "!" );
			setTimeout( function():void {
				requestHidePopUpSignal.dispatch();
			}, 1000 );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToRegister( email:String, password:String, firstName:String, lastName:String, photo:BitmapData ):void {
			var vo:UserRegistrationVO = new UserRegistrationVO();
			vo.email = email;
			vo.password = password;
			vo.firstName = firstName;
			vo.lastName = lastName;
			loggedInUserProxy.registerAndLogIn( vo );
		}

		private function onForgottenPassword():void {
			view.loginSubView.displayCenterMessage( LoginCopy.WAITING );
			// TODO: call service here and listen for reply to display a message below the login button, then dismiss the pop up?
			// LoginCopy.as -> PASSWORD_REMINDER
		}

		private function onPopUpWantsToLogIn( email:String, password:String ):void {
			view.loginSubView.displayCenterMessage( LoginCopy.WAITING );
			loggedInUserProxy.logIn( email, password );
		}

		private function onPopUpWantsToClose():void {
			requestHidePopUpSignal.dispatch();
		}
	}
}
