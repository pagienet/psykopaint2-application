package net.psykosoft.psykopaint2.core.models
{
	public interface LoggedInUserProxy
	{
		function isLoggedIn() : Boolean;
		function logIn(username : String, password : String) : void;
		function get userID() : int;
	}
}
