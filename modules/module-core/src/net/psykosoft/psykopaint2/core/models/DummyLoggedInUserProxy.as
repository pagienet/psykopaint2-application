package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import org.osflash.signals.Signal;

	public class DummyLoggedInUserProxy implements LoggedInUserProxy
	{
		private var _userID : int = -1;
		private var _sessionID : String;
		private var _firstName : String;
		private var _lastName : String;
		private var _facebookID : uint;
		private var _numComments : uint;
		private var _numFollowers : uint;
		private var _active : Boolean;
		private var _banned : Boolean;

		private var _onChange : Signal = new Signal();

		public function DummyLoggedInUserProxy()
		{
		}

		public function sendPasswordReminder(email : String, onSuccess : Function, onFail : Function) : void
		{
			// Does nothing.
		}

		public function sendProfileImages(imageLarge : ByteArray, imageSmall : ByteArray) : void
		{
			// Does nothing.
			trace(this, "sendProfileImages...");
		}

		public function isLoggedIn() : Boolean
		{
			return _userID != -1;
		}

		public function logIn(email : String, password : String, onSuccess : Function, onFail : Function) : void
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

			// Panic not! This time out is ok, it's just for testing...
			setTimeout(function () : void
			{
				// Pick one.
				_onChange.dispatch();
				onSuccess();
//				notifyUserLogInFailedSignal.dispatch( AMFErrorCode.CALL_STATUS_FAILED, "EMAIL" );
//				notifyUserLogInFailedSignal.dispatch( AMFErrorCode.CALL_STATUS_FAILED, "PASSWORD" );
//				notifyUserLogInFailedSignal.dispatch( AMFErrorCode.CONNECTION_IO_ERROR, "" );
			}, 2000);
		}

		public function registerAndLogIn(userRegisterationVO : UserRegistrationVO, onSuccess : Function, onFail : Function) : void
		{
			trace(this, "registering...");

			_userID = 1;
			_sessionID = "1";

			_firstName = userRegisterationVO.firstName;
			_lastName = userRegisterationVO.lastName;
			_facebookID = userRegisterationVO.facebookID;
			_numComments = 0;
			_numFollowers = 0;
			_active = true;
			_banned = false;

			setTimeout(function () : void
			{
				_onChange.dispatch();
				onSuccess();
			}, 3000);
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

		public function logOut(onSuccess : Function, onFail : Function) : void
		{
			_sessionID = null;
			_userID = -1;

			setTimeout(function () : void
			{
				_onChange.dispatch();
				onSuccess();
			}, 1000);
		}

		public function get onChange():Signal
		{
			return _onChange;
		}
	}
}
