package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyPasswordResetFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPasswordResetSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogOutFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedOutSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserPasswordReminderSentSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegisteredSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegistrationFailedSignal;

	public class AMFLoggedInUserProxy implements LoggedInUserProxy
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var notifyUserLoggedInSignal : NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal : NotifyUserLogInFailedSignal;

		[Inject]
		public var notifyUserLoggedOutSignal : NotifyUserLoggedOutSignal;

		[Inject]
		public var notifyUserLogOutFailedSignal : NotifyUserLogOutFailedSignal;

		[Inject]
		public var notifyUserRegistrationFailedSignal : NotifyUserRegistrationFailedSignal;

		[Inject]
		public var notifyUserRegisteredSignal : NotifyUserRegisteredSignal;

		[Inject]
		public var notifyPasswordResetSucceededSignal : NotifyPasswordResetSucceededSignal;

		[Inject]
		public var notifyPasswordResetFailedSignal : NotifyPasswordResetFailedSignal;

		[Inject]
		public var notifyUserPasswordReminderSentSignal:NotifyUserPasswordReminderSentSignal;

		[Inject]
		public var notifyUserPasswordReminderFailedSignal:NotifyUserPasswordReminderFailedSignal;

		private var _userID : int = -1;

		private var _sessionID : String;
		private var _firstName : String;
		private var _lastName : String;
		private var _facebookID : uint;
		private var _numComments : uint;
		private var _numFollowers : uint;
		private var _active : Boolean;
		private var _banned : Boolean;
		private var _passwordReminderEmail:String;

		public function AMFLoggedInUserProxy()
		{
		}

		public function sendPasswordReminder( email:String ):void {
			_passwordReminderEmail = email;
			amfBridge.passwordReset( email, onSendPasswordReminderSuccess, onSendPasswordReminderFailure );
		}

		private function onSendPasswordReminderSuccess( data:Object ):void {
			notifyUserPasswordReminderSentSignal.dispatch( _passwordReminderEmail );
			_passwordReminderEmail = null;
		}

		private function onSendPasswordReminderFailure( data:Object ):void {
			notifyUserPasswordReminderFailedSignal.dispatch( data["status_code"] );
			_passwordReminderEmail = null;
		}

		public function sendProfileImages( imageLarge:ByteArray, imageSmall:ByteArray ) : void
		{
			amfBridge.setProfileImage( _sessionID, imageLarge, imageSmall );
		}

		public function isLoggedIn() : Boolean
		{
			return _userID != -1;
		}

		public function logIn(email : String, password : String) : void
		{
			amfBridge.logIn(email, password, onLogInSuccess, onLogInFail);
			_userID = 1;
		}

		public function registerAndLogIn(userRegistrationVO : UserRegistrationVO) : void
		{
			amfBridge.registerAndLogIn(userRegistrationVO, onRegisterSuccess, onRegisterFail);
		}

		private function onRegisterSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				notifyUserRegistrationFailedSignal.dispatch(data["status_code"], data["status_reason"]);
				return;
			}

			populateUserData(data);
			notifyUserRegisteredSignal.dispatch();
			notifyUserLoggedInSignal.dispatch();
		}

		private function onRegisterFail(data : Object) : void
		{
			notifyUserRegistrationFailedSignal.dispatch(data["status_code"], data["status_reason"]);
		}

		public function logOut() : void
		{
			amfBridge.logOut(_sessionID, onLogOutSuccess, onLogOutFail);
		}

		private function onLogOutSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				notifyUserLogOutFailedSignal.dispatch(data["status_code"], "FAIL");
				return;
			}
			_userID = -1;
			_sessionID = null;
			_facebookID = 0;
			_active = false;
			_banned = false;
			_firstName = null;
			_lastName = null;
			_numComments = 0;
			_numFollowers = 0;
		}

		private function onLogOutFail(data : Object) : void
		{
			notifyUserLogOutFailedSignal.dispatch(AMFErrorCode.CALL_FAILED, "CALL_FAILED");
		}

		private function onLogInSuccess(data : Object) : void
		{
//			traceResponse("onLogInSuccess - (server responded): ", data);

			if (data["status_code"] != 1) {
				var firstname:String = "";
				if(data["status_code"] == 2) {
					if( data["response"] && data["response"]["firstname"] ) {
						firstname = data["response"]["firstname"];
					}
//					trace("> " + firstname);
				}
				notifyUserLogInFailedSignal.dispatch(data["status_code"], data["status_reason"], firstname);
				return;
			}

			populateUserData(data);
			notifyUserLoggedInSignal.dispatch();
		}

		private function onLogInFail(data : Object) : void
		{
			notifyUserLogInFailedSignal.dispatch(AMFErrorCode.CALL_FAILED, "CALL_FAILED", "");
		}

		private function populateUserData(data : Object) : void
		{
			_sessionID = data["session_id"];

			var userData : Object = data["response"];
			_userID = userData["id"];
			_firstName = userData["firstname"];
			_lastName = userData["lastname"];
			_facebookID = userData["facebook_id"];
			_numFollowers = userData["num_followers"];
			_numComments = userData["num_comments"];
			_active = userData["active"];
			_banned = userData["banned"];
		}

		public function requestPasswordReset(email : String) : void
		{
			amfBridge.logOut(email, onPasswordResetSuccess, onPasswordResetFail);
		}

		private function onPasswordResetFail(data : Object) : void
		{
			notifyPasswordResetFailedSignal.dispatch(data["status_code"], "CALL_FAILED");
		}

		private function onPasswordResetSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				notifyPasswordResetFailedSignal	.dispatch(data["status_code"], data["status_reason"]);
				return;
			}

			notifyPasswordResetSucceededSignal.dispatch();
		}

		public function get sessionID() : String
		{
			return _sessionID;
		}

		public function get userID() : int
		{
			return _userID;
		}

		public function get firstName() : String
		{
			return _firstName;
		}

		public function get lastName() : String
		{
			return _lastName;
		}

		public function get facebookID() : uint
		{
			return _facebookID;
		}

		public function get numFollowers() : uint
		{
			return _numFollowers;
		}

		public function get numComments() : uint
		{
			return _numComments;
		}

		public function get active() : Boolean
		{
			return _active;
		}

		public function get banned() : Boolean
		{
			return _banned;
		}

		private function traceResponse( msg:String, data:Object ):void {
			trace(msg + ": " + data); for (var i in data) trace(i+" = "+data[i]);
		}
	}
}
