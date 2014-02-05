package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.base.utils.misc.StringUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.UserRegistrationVO;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderSentSignal;
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
		public var notifyUserLoggedInSignal:NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal:NotifyUserLogInFailedSignal;

		[Inject]
		public var notifyUserRegistrationFailedSignal:NotifyUserRegistrationFailedSignal;

		[Inject]
		public var notifyUserRegisteredSignal:NotifyUserRegisteredSignal;

		[Inject]
		public var notifyUserPasswordReminderSentSignal:NotifyUserPasswordReminderSentSignal;

		[Inject]
		public var notifyUserPasswordReminderFailedSignal:NotifyUserPasswordReminderFailedSignal;

		[Inject]
		public var notifyAMFConnectionFailed : NotifyAMFConnectionFailed;

		private var _photoLarge:BitmapData;
		private var _photoSmall:BitmapData;
		private var _loggingIn:Boolean;
		private var _signingUp:Boolean;

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
			notifyUserPasswordReminderSentSignal.add( onPasswordReminderSent );
			notifyUserPasswordReminderFailedSignal.add( onPasswordReminderFailed );
			notifyAMFConnectionFailed.add( onConnectionProblems );
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
			notifyUserPasswordReminderSentSignal.remove( onPasswordReminderSent );
			notifyUserPasswordReminderFailedSignal.remove( onPasswordReminderFailed );
			notifyAMFConnectionFailed.remove( onConnectionProblems );
			if( _photoLarge ) _photoLarge.dispose();
			if( _photoSmall ) _photoSmall.dispose();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onRegisterFailure( amfErrorCode:int, reason:String ):void {
			view.signupSubView.signupBtn.dontSpin();

			trace( this, "register failed - error code: " + amfErrorCode + ", reason: " + reason );
			// Error feedback.
			if( amfErrorCode == AMFErrorCode.CALL_STATUS_FAILED ) { // LOGIN REJECTED
				if( reason == "EMAIL_EXISTS" ) {
					view.signupSubView.rejectEmail();
					view.signupSubView.displaySatelliteMessage( view.signupSubView.emailTf, LoginCopy.ALREADY_REGISTERED );
				}
			}
			else {
				displayGenericSignUpConnectionError();
			}

			view.signupSubView.canRequestSignUp = true;
			_signingUp = false;
		}

		private function onRegisterSuccess():void {

			trace( this, "registered" );

			view.signupSubView.signupBtn.dontSpin();

			// Send profile images using a separate service call.
			var largeBytes:TrackedByteArray = new TrackedByteArray();
			_photoLarge.copyPixelsToByteArray( _photoLarge.rect, largeBytes );
			var smallBytes:TrackedByteArray = new TrackedByteArray();
			_photoSmall.copyPixelsToByteArray( _photoSmall.rect, smallBytes );
			loggedInUserProxy.sendProfileImages( largeBytes, smallBytes );

			view.signupSubView.canRequestSignUp = true;
			_signingUp = false;
		}

		// the fail signal contains an int with a value from AMFErrorCode.as
		private function onLoginFailure( amfErrorCode:int, reason:String, firstname:String ):void {

			trace( this, "login failed - error code: " + amfErrorCode );
			view.loginSubView.loginBtn.dontSpin();

			// Error feedback.
			if( amfErrorCode == AMFErrorCode.CALL_STATUS_FAILED ) { // LOGIN REJECTED
				if( reason == "EMAIL" ) {
					view.loginSubView.rejectEmail();
					view.loginSubView.displaySatelliteMessage( view.loginSubView.emailInput, LoginCopy.NOT_REGISTERED );
				}
				else { // User was recognized but password was rejected.
					view.loginSubView.rejectPassword();

					var dynamicCopy:String = StringUtil.replaceWordWith( LoginCopy.INCORRECT_PASSWORD, "[firstname]", firstname );
					view.loginSubView.displaySatelliteMessage( view.loginSubView.passwordInput, dynamicCopy );
				}
			}
			else {
				displayGenericLoginConnectionError();
			}

			view.loginSubView.canRequestLogin = true;
			_loggingIn = false;
		}

		private function onLoginSuccess():void {

			view.loginSubView.loginBtn.dontSpin();

			trace( this, "logged in" );
			requestHidePopUpSignal.dispatch();

			view.loginSubView.canRequestLogin = true;
			_loggingIn = false;
		}

		private function onPasswordReminderFailed( amfErrorCode:int ):void {
			view.loginSubView.displaySatelliteMessage( view.loginSubView.forgotButton, LoginCopy.ERROR, view.loginSubView.forgotButton.width / 2, view.loginSubView.forgotButton.height / 2 );
			view.loginSubView.canRequestReminder = true;
		}

		private function onPasswordReminderSent( email:String ):void {
			view.loginSubView.clearAllSatelliteMessages();

			var dynamicCopy:String = StringUtil.replaceWordWith( LoginCopy.PASSWORD_REMINDER, "[email]", email );
			view.loginSubView.displaySatelliteMessage( view.loginSubView.emailInput, dynamicCopy );

			view.loginSubView.canRequestReminder = true;
		}

		private function onConnectionProblems( errorCode:int ):void {
			if(_loggingIn) {
				view.loginSubView.loginBtn.dontSpin();
				displayGenericLoginConnectionError();
				_loggingIn = false;
			}
			if(_signingUp) {
				view.signupSubView.signupBtn.dontSpin();
				displayGenericSignUpConnectionError();
				_signingUp = false;
			}
		}

		private function displayGenericLoginConnectionError():void {
			view.loginSubView.displaySatelliteMessage( view.loginSubView.loginBtn, LoginCopy.ERROR, view.loginSubView.loginBtn.width / 2, view.loginSubView.loginBtn.height / 2 );
		}

		private function displayGenericSignUpConnectionError():void {
			view.signupSubView.displaySatelliteMessage( view.signupSubView.signupBtn, LoginCopy.ERROR, view.signupSubView.signupBtn.width / 2 - 25, view.signupSubView.signupBtn.height / 2 - 25, -15 );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToRegister( email:String, password:String, firstName:String, lastName:String, photoLarge:BitmapData, photoSmall:BitmapData ):void {

			_signingUp = true;
			view.signupSubView.signupBtn.spin();

			// Remember these so we can upload them only after the string part of the registration is done.
			_photoLarge = photoLarge;
			_photoSmall = photoSmall;

			// Register.
			var vo:UserRegistrationVO = new UserRegistrationVO();
			vo.email = email;
			vo.password = password;
			vo.firstName = firstName;
			vo.lastName = lastName;
			loggedInUserProxy.registerAndLogIn( vo );

			view.signupSubView.canRequestSignUp = false;
		}

		private function onForgottenPassword( email:String ):void {
			view.loginSubView.canRequestReminder = false;
			loggedInUserProxy.sendPasswordReminder( email );
		}

		private function onPopUpWantsToLogIn( email:String, password:String ):void {
			_loggingIn = true;
			view.loginSubView.loginBtn.spin();
			view.loginSubView.canRequestLogin = false;
			loggedInUserProxy.logIn( email, password );
		}

		private function onPopUpWantsToClose():void {
			requestHidePopUpSignal.dispatch();
		}
	}
}
