package net.psykosoft.psykopaint2.core.models
{
	public class DummyLoggedInUserProxy implements LoggedInUserProxy
	{
		private var _userID : int = -1;

		public function DummyLoggedInUserProxy()
		{
		}

		public function isLoggedIn() : Boolean
		{
			return _userID != -1;
		}

		public function logIn(username : String, password : String) : void
		{
			_userID = 1;
		}

		public function get userID() : int
		{
			return _userID;
		}
	}
}
