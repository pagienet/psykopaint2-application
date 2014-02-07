package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;

	import org.osflash.signals.Signal;

	public class AMFLoggedInUserProxy implements LoggedInUserProxy
	{
		[Inject]
		public var amfBridge : AMFBridge;

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

		private var _onChange : Signal = new Signal();

		private var _onFail : Function;
		private var _onSuccess : Function;

		public function AMFLoggedInUserProxy()
		{
		}

		public function sendPasswordReminder( email:String, onSuccess : Function, onFail : Function ):void {
			_onFail = onFail;
			_onSuccess = onSuccess;
			_passwordReminderEmail = email;
			amfBridge.passwordReset( email, onSendPasswordReminderSuccess, onSendPasswordReminderFailure );
		}

		private function onSendPasswordReminderSuccess( data:Object ):void {
			if (_onSuccess) _onSuccess(_passwordReminderEmail);
			_passwordReminderEmail = null;
		}

		private function onSendPasswordReminderFailure( data:Object ):void {
			_onFail( data["status_code"] );
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

		public function logIn(email : String, password : String, onSuccess : Function, onFail : Function) : void
		{
			_onSuccess = onSuccess;
			_onFail = onFail;
			amfBridge.logIn(email, password, onLogInSuccess, onLogInFail);
			_userID = 1;
		}

		public function registerAndLogIn(userRegistrationVO : UserRegistrationVO, onSuccess : Function, onFail : Function) : void
		{
			_onSuccess = onSuccess;
			_onFail = onFail;
			amfBridge.registerAndLogIn(userRegistrationVO, onRegisterSuccess, onRegisterFail);
		}

		private function onRegisterSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				_onFail(data["status_code"], data["status_reason"]);
				return;
			}

			populateUserData(data);
			_onChange.dispatch();
			if (_onSuccess) _onSuccess();
		}

		private function onRegisterFail(data : Object) : void
		{
			_onFail(data["status_code"], data["status_reason"]);
		}

		public function logOut(onSuccess : Function, onFail : Function) : void
		{
			_onFail = onFail;
			_onSuccess = onSuccess;
			amfBridge.logOut(_sessionID, onLogOutSuccess, onLogOutFail);
		}

		private function onLogOutSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				_onFail(data["status_code"], "FAIL");
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
			if (_onSuccess) _onSuccess();
		}

		private function onLogOutFail(data : Object) : void
		{
			_onFail(AMFErrorCode.CALL_FAILED, "CALL_FAILED");
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
				_onFail(data["status_code"], data["status_reason"], firstname);
				return;
			}

			populateUserData(data);
			_onChange.dispatch();
			if (_onSuccess) _onSuccess();
		}

		private function onLogInFail(data : Object) : void
		{
			_onFail(AMFErrorCode.CALL_FAILED, "CALL_FAILED", "");
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

		public function get onChange():Signal
		{
			return _onChange;
		}
	}
}
