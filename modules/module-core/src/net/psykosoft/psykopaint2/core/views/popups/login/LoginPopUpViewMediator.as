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
			view.signupSubView.signupBtn.dontSpin();
			trace( this, "register failed - error code: " + amfErrorCode );
			// TODO: give feedback about error via view.signupSubView.displaySatelliteMessage()
			view.signupSubView.rejectPassword();
		}

		private function onRegisterSuccess():void {
			view.signupSubView.signupBtn.dontSpin();
			trace( this, "registered" );
		}

		// the fail signal contains an int with a value from AMFErrorCode.as
		private function onLoginFailure( amfErrorCode:int ):void {
			view.loginSubView.loginBtn.dontSpin();
			trace( this, "login failed - error code: " + amfErrorCode );
			// TODO: give feedback about error via view.loginSubView.displaySatelliteMessage()
			view.loginSubView.rejectPassword();
		}

		private function onLoginSuccess():void {
			view.loginSubView.loginBtn.dontSpin();
			trace( this, "logged in" );
			setTimeout( function():void {
				requestHidePopUpSignal.dispatch();
			}, 1000 );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToRegister( email:String, password:String, firstName:String, lastName:String, photo:BitmapData ):void {
			view.signupSubView.signupBtn.spin();
			var vo:UserRegistrationVO = new UserRegistrationVO();
			vo.email = email;
			vo.password = password;
			vo.firstName = firstName;
			vo.lastName = lastName;
			loggedInUserProxy.registerAndLogIn( vo );
			// TODO: send photo/photos via separate setProfilePicture() method
		}

		private function onForgottenPassword( email:String ):void {
			loggedInUserProxy.sendPasswordReminder( email );
			view.loginSubView.clearAllSatelliteMessages();
			view.loginSubView.displaySatelliteMessage( view.loginSubView.emailInput, LoginCopy.PASSWORD_REMINDER );
		}

		private function onPopUpWantsToLogIn( email:String, password:String ):void {
			view.loginSubView.loginBtn.spin();
			loggedInUserProxy.logIn( email, password );
		}

		private function onPopUpWantsToClose():void {
			requestHidePopUpSignal.dispatch();
		}
	}
}
