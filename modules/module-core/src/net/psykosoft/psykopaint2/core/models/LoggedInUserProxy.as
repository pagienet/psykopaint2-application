package net.psykosoft.psykopaint2.core.models
{

	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public interface LoggedInUserProxy
	{
		function isLoggedIn() : Boolean;

		function logIn(username : String, password : String, onSuccess : Function, onFail : Function) : void;

		function logOut(onSuccess : Function, onFail : Function) : void;

		function registerAndLogIn(userRegistrationVO : UserRegistrationVO, onSuccess : Function, onFail : Function) : void;

		function sendPasswordReminder(email : String, onSuccess : Function, onFail : Function) : void

		function sendProfileImages(imageLarge : ByteArray, imageSmall : ByteArray) : void;

		function loadUserImage():void;

		function get userID() : int;

		function get sessionID() : String;

		function get firstName() : String;

		function get lastName() : String;

		function get facebookID() : uint;

		function get numFollowers() : uint;

		function get numComments() : uint;

		function get active() : Boolean;

		function get banned() : Boolean;

		function get onChange():Signal;
		function get onSubscriptionsChanged():Signal;

		function get hasNotificationSubscriptions():Boolean;
		function hasNotificationSubscription(type : int):Boolean;

		function subscribeNotification(type:int, subscribed : Boolean, onSuccess:Function, onFail:Function):void;

		function getIsFollowingUser(userID : int, onSuccess:Function, onFail:Function) : void;

		function unfollowUser(userID : int, onSuccess:Function, onFail:Function) : void;

		function followUser(userID : int, onSuccess:Function, onFail:Function) : void;
	}
}
