package net.psykosoft.psykopaint2.core.models
{
	public interface LoggedInUserProxy
	{
		function isLoggedIn() : Boolean;
		function logIn(username : String, password : String) : void;
		function logOut() : void;
		function registerAndLogIn(userRegistrationVO : UserRegistrationVO) : void;
		function sendPasswordReminder( email:String ):void

		function get userID() : int;
		function get sessionID() : String;
		function get firstName() : String;
		function get lastName() : String;
		function get facebookID() : uint;
		function get numFollowers() : uint;
		function get numComments() : uint;
		function get active() : Boolean;
		function get banned() : Boolean;
	}
}
