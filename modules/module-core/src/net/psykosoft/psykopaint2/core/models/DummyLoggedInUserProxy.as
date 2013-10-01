package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserRegisteredSignal;

	public class DummyLoggedInUserProxy implements LoggedInUserProxy
	{
		[Inject]
		public var notifyUserLoggedInSignal : NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal:NotifyUserLogInFailedSignal;

		[Inject]
		public var notifyUserRegisteredSignal : NotifyUserRegisteredSignal;

		private var _userID : int = -1;
		private var _sessionID : String;
		private var _firstName : String;
		private var _lastName : String;
		private var _facebookID : uint;
		private var _numComments : uint;
		private var _numFollowers : uint;
		private var _active : Boolean;
		private var _banned : Boolean;

		public function DummyLoggedInUserProxy()
		{
		}

		public function isLoggedIn() : Boolean
		{
			return _userID != -1;
		}

		public function logIn(email : String, password : String) : void
		{
			_userID = 1;
			_sessionID = "1";

			_firstName = "Benny";
			_lastName = "Lava";
			_facebookID = 0;
			_numComments = 3;
			_numFollowers = 5;
			_active = true;
			_banned = false;

			setTimeout( function():void {
				// Pick one.
				notifyUserLoggedInSignal.dispatch();
//				notifyUserLogInFailedSignal.dispatch( AMFErrorCode.CALL_STATUS_AUTH_ERROR );
			}, 2000 );
		}

		public function registerAndLogIn(userRegisterationVO : UserRegistrationVO) : void
		{
			_userID = 1;
			_sessionID = "1";

			_firstName = userRegisterationVO.firstName;
			_lastName = userRegisterationVO.lastName;
			_facebookID = userRegisterationVO.facebookID;
			_numComments = 0;
			_numFollowers = 0;
			_active = true;
			_banned = false;

			setTimeout( function():void {
				notifyUserRegisteredSignal.dispatch();
				notifyUserLoggedInSignal.dispatch();
			}, 3000 );
		}

		public function get userID() : int
		{
			return _userID;
		}

		public function get sessionID() : String
		{
			return _sessionID;
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
