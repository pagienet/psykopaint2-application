package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;

	public class AMFLoggedInUserProxy implements LoggedInUserProxy
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var notifyUserLoggedInSignal : NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal : NotifyUserLogInFailedSignal;

		private var _userID : int = -1;

		private var _sessionID : String;
		private var _firstName : String;
		private var _lastName : String;
		private var _facebookID : uint;
		private var _numComments : uint;
		private var _numFollowers : uint;
		private var _active : Boolean;
		private var _banned : Boolean;

		public function AMFLoggedInUserProxy()
		{
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

		private function onLogInSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				notifyUserLogInFailedSignal.dispatch(data["status_code"]);
				return;
			}

			_sessionID = data["session_id"];

			var userData : Object = data["userData"];
			_userID = userData["id"];
			_firstName = userData["firstname"];
			_lastName = userData["lastname"];
			_facebookID = userData["facebook_id"];
			_numFollowers = userData["num_followers"];
			_numComments = userData["num_comments"];
			_active = userData["active"];
			_banned = userData["banned"];

			notifyUserLoggedInSignal.dispatch();
		}

		private function onLogInFail(data : Object) : void
		{
			notifyUserLogInFailedSignal.dispatch(AMFErrorCode.CALL_FAILED);
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
	}
}
