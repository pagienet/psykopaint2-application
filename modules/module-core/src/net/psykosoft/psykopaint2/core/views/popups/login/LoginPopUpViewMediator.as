package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.UserRegistrationVO;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
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
		public var notifyUserLoggedInSignal:NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal:NotifyUserLogInFailedSignal;

		[Inject]
		public var notifyUserRegistrationFailedSignal:NotifyUserRegistrationFailedSignal;

		[Inject]
		public var notifyUserRegisteredSignal:NotifyUserRegisteredSignal;

		private var _photoLarge:BitmapData;
		private var _photoSmall:BitmapData;

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
			if( _photoLarge ) _photoLarge.dispose();
			if( _photoSmall ) _photoSmall.dispose();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onRegisterFailure( amfErrorCode:int, reason:String ):void {
			view.signupSubView.signupBtn.dontSpin();
			trace( this, "register failed - error code: " + amfErrorCode );
			// TODO: give feedback about error via view.signupSubView.displaySatelliteMessage()
			view.signupSubView.rejectPassword();
		}

		private function onRegisterSuccess():void {

			trace( this, "registered" );

			view.signupSubView.signupBtn.dontSpin();

			// Send profile images using a separate service call.
			var largeBytes:ByteArray = new ByteArray();
			_photoLarge.copyPixelsToByteArray( _photoLarge.rect, largeBytes );
			var smallBytes:ByteArray = new ByteArray();
			_photoSmall.copyPixelsToByteArray( _photoSmall.rect, smallBytes );
			loggedInUserProxy.sendProfileImages( largeBytes, smallBytes );
		}

		// the fail signal contains an int with a value from AMFErrorCode.as
		private function onLoginFailure( amfErrorCode:int, reason:String ):void {

			trace( this, "login failed - error code: " + amfErrorCode );
			view.loginSubView.loginBtn.dontSpin();

			// Error feedback.
			if( amfErrorCode == AMFErrorCode.CALL_STATUS_FAILED ) { // LOGIN REJECTED
				if( reason == "EMAIL" ) {
					view.loginSubView.rejectEmail();
					view.loginSubView.displaySatelliteMessage( view.loginSubView.emailInput, LoginCopy.NOT_REGISTERED );
				}
				else {
					view.loginSubView.rejectPassword();
					view.loginSubView.displaySatelliteMessage( view.loginSubView.passwordInput, LoginCopy.INCORRECT_PASSWORD );
				}
			}
			else {
				view.loginSubView.displaySatelliteMessage( view.loginSubView.loginBtn, LoginCopy.ERROR, view.loginSubView.loginBtn.width / 2, view.loginSubView.loginBtn.height / 2 );
			}
		}

		private function onLoginSuccess():void {

			view.loginSubView.loginBtn.dontSpin();

			trace( this, "logged in" );
			requestHidePopUpSignal.dispatch();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToRegister( email:String, password:String, firstName:String, lastName:String, photoLarge:BitmapData, photoSmall:BitmapData ):void {

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
