package net.psykosoft.psykopaint2.core.models
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.services.AMFErrorCode;
	import net.psykosoft.psykopaint2.core.signals.NotifyProfilePictureUpdatedSignal;

	import org.osflash.signals.Signal;

	public class AMFLoggedInUserProxy implements LoggedInUserProxy
	{
		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var notifyProfilePictureUpdatedSignal : NotifyProfilePictureUpdatedSignal;

		private var _userID : int = -1;

		private var _sessionID : String;
		private var _firstName : String;
		private var _lastName : String;
		private var _facebookID : uint;
		private var _numComments : uint;
		private var _numFollowers : uint;
		private var _active : Boolean;
		private var _banned : Boolean;
		private var _passwordReminderEmail : String;

		private var _onChange : Signal = new Signal();
		private var _onSubscriptionsChange : Signal = new Signal();

		private var _onFail : Function;
		private var _onSuccess : Function;

		private var _localCache : SharedObject;
		private var _subscriptions : Array;
		private var _toFollowUserID : int;
		private var _thumbnailURL:String;

		public function AMFLoggedInUserProxy()
		{
			_localCache = SharedObject.getLocal("com.psykopaint.userData");
		}

		[PostConstruct]
		public function init() : void
		{
			retrieveCachedUser();
		}

		private function retrieveCachedUser() : void
		{
			_sessionID = _localCache.data["session_id"];

			if (_sessionID) {
				extractProfileData(_localCache.data);
				loadUserImage();
			}
			else
				_userID = -1;
		}

		public function sendPasswordReminder(email : String, onSuccess : Function, onFail : Function) : void
		{
			_onFail = onFail;
			_onSuccess = onSuccess;
			_passwordReminderEmail = email;
			amfBridge.requestResetPassword(email, onSendPasswordReminderSuccess, onSendPasswordReminderFailure);
		}

		private function onSendPasswordReminderSuccess(data : Object) : void
		{
			if (_onSuccess) _onSuccess(_passwordReminderEmail);
			_passwordReminderEmail = null;
		}

		private function onSendPasswordReminderFailure(data : Object) : void
		{
			_onFail(data["status_code"]);
			_passwordReminderEmail = null;
		}

		public function sendProfileImages(imageLarge : ByteArray, imageSmall : ByteArray) : void
		{
			amfBridge.setProfileImage(_sessionID, imageLarge, imageSmall);
		}

		public function isLoggedIn() : Boolean
		{
			return _userID != -1;
		}

		public function logIn(email : String, password : String, onSuccess : Function, onFail : Function) : void
		{
			_onSuccess = onSuccess;
			_onFail = onFail;
			amfBridge.logIn(email, password, onLogInSuccess, onGeneralFail);
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
			_onSubscriptionsChange.dispatch();
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

			amfBridge.logOut(_sessionID, onGeneralSuccess, onGeneralFail);

			// clear local data regardless of success, if offline, session will simply expire
			_userID = -1;
			_sessionID = null;
			_facebookID = 0;
			_active = false;
			_banned = false;
			_firstName = null;
			_lastName = null;
			_numComments = 0;
			_numFollowers = 0;

			cacheUserData();

			_onChange.dispatch();
			_onSubscriptionsChange.dispatch();
			notifyProfilePictureUpdatedSignal.dispatch(null);
		}

		private function onGeneralSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				_onFail(data["status_code"], "FAIL");
				return;
			}

			if (_onSuccess) _onSuccess();
		}

		private function onGeneralFail(data : Object) : void
		{
			_onFail(AMFErrorCode.CALL_FAILED, "CALL_FAILED");
		}

		private function onLogInSuccess(data : Object) : void
		{
//			traceResponse("onLogInSuccess - (server responded): ", data);

			if (data["status_code"] != 1) {
				var firstname : String = "";
				if (data["status_code"] == 2) {
					if (data["response"] && data["response"]["firstname"]) {
						firstname = data["response"]["firstname"];
					}
//					trace("> " + firstname);
				}
				_onFail(data["status_code"], data["status_reason"], firstname);
				return;
			}

			populateUserData(data);

			_onChange.dispatch();
			_onSubscriptionsChange.dispatch();
			if (_onSuccess) _onSuccess();

			loadUserImage();
		}

		public function loadUserImage():void
		{
			var loader : Loader = new Loader();
			if (_thumbnailURL && _thumbnailURL != "") {
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImageComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadImageError);
				loader.load(new URLRequest(_thumbnailURL));
			}
			else
				notifyProfilePictureUpdatedSignal.dispatch(null);
		}

		private function onLoadImageError(event:IOErrorEvent):void
		{
			var loader : LoaderInfo = LoaderInfo(event.target);
			loader.removeEventListener(Event.COMPLETE, onLoadImageComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadImageError);
			notifyProfilePictureUpdatedSignal.dispatch(null);
		}

		private function onLoadImageComplete(event:Event):void
		{
			var loader : Loader = LoaderInfo(event.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImageComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadImageError);
			var bitmapData : BitmapData = Bitmap(loader.content).bitmapData;
			notifyProfilePictureUpdatedSignal.dispatch(bitmapData);
		}

		private function populateUserData(data : Object) : void
		{
			_sessionID = data["session_id"];
			extractProfileData(data["response"]);
			cacheUserData();
		}

		private function cacheUserData() : void
		{
			_localCache.data["session_id"] = _sessionID;
			_localCache.data["id"] = _userID;
			_localCache.data["firstname"] = _firstName;
			_localCache.data["lastname"] = _lastName;
			_localCache.data["facebook_id"] = _facebookID;
			_localCache.data["num_followers"] = _numFollowers;
			_localCache.data["num_comments"] = _numComments;
			_localCache.data["active"] = _active;
			_localCache.data["banned"] = _banned;
			_localCache.data["notifications"] = _subscriptions;
			_localCache.data["thumbnail_url"] = _thumbnailURL;
			_localCache.flush();
		}

		private function extractProfileData(userData : Object) : void
		{
			_userID = userData["id"];
			_firstName = userData["firstname"];
			_lastName = userData["lastname"];
			_facebookID = userData["facebook_id"];
			_numFollowers = userData["num_followers"];
			_numComments = userData["num_comments"];
			_active = userData["active"];
			_banned = userData["banned"];
			_subscriptions = userData["notifications"];
			_thumbnailURL = userData["thumbnail_url"];

			if (_subscriptions) {
				for (var i : int = 0; i < _subscriptions.length; ++i) {
					trace("Notification subscription: " + _subscriptions[i]["notification_type"] + ": " + _subscriptions[i]["subscribed"]);
				}
			}
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

		public function get onChange() : Signal
		{
			return _onChange;
		}

		public function get onSubscriptionsChanged() : Signal
		{
			return _onSubscriptionsChange;
		}

		public function subscribeNotification(type : int, subscribed : Boolean, onSuccess : Function, onFail : Function) : void
		{
			var oldValue : Boolean;
			var subscriptionData : Object;

			for (var i : int = 0; i < _subscriptions.length; ++i) {
				subscriptionData = _subscriptions[i];

				if (subscriptionData["notification_type"] == type) {
					oldValue = subscriptionData["subscribed"];
					subscriptionData["subscribed"] = subscribed;
					break;
				}
			}

			_onSuccess = onSuccess;
			_onFail = onFail;

			amfBridge.updateSubscription(_sessionID, type, subscribed,
					onUpdateSubscriptionsSuccess,
					function (data : Object) : void
					{
						trace("Successfully updated call failed");
						subscriptionData["subscribed"] = oldValue;
						onFail();
					}
			);
		}

		private function onUpdateSubscriptionsSuccess(data : Object) : void
		{
			if (data["status_code"] != 1) {
				trace("Updating subscriptions failed: code " + data["status_code"]);
				_onFail();
				return;
			}

			trace("Successfully updated subscriptions");
			cacheUserData();
			_onSubscriptionsChange.dispatch();
			_onSuccess();
		}

		public function get hasNotificationSubscriptions() : Boolean
		{
			if (!_subscriptions) return false;

			for (var i : int = 0; i < _subscriptions.length; ++i) {
				if (_subscriptions[i]["subscribed"])
					return true;
			}

			return false;
		}

		public function hasNotificationSubscription(type : int) : Boolean
		{
			if (!_subscriptions) return false;

			for (var i : int = 0; i < _subscriptions.length; ++i) {
				if (_subscriptions[i]["notification_type"] == type)
					return _subscriptions[i]["subscribed"];
			}

			return false;
		}

		public function getIsFollowingUser(userID : int, onSuccess : Function, onFail : Function) : void
		{
			_toFollowUserID = userID;
			_onFail = onFail;
			_onSuccess = onSuccess;
			amfBridge.getFollowedUsers(_sessionID, onGetIsFollowingUserResult, onGeneralFail);
		}

		private function onGetIsFollowingUserResult(data : Object) : void
		{
			if (data["status_code"] != 1) {
				trace("Updating subscriptions failed: code " + data["status_code"]);
				_toFollowUserID = -1;
				_onFail(data["status_code"], data["status_reason"]);
				return;
			}

			var response : Array = data["response"];
			for each(var user : Object in response) {
				if (user.id == _toFollowUserID) {
					_onSuccess(true);
					_toFollowUserID = -1;
					return;
				}
			}

			_toFollowUserID = -1;
			_onSuccess(false);
		}

		public function unfollowUser(userID : int, onSuccess : Function, onFail : Function) : void
		{
			_onFail = onFail;
			_onSuccess = onSuccess;
			amfBridge.unfollowUser(_sessionID, userID, onGeneralSuccess, onGeneralFail);
		}

		public function followUser(userID : int, onSuccess : Function, onFail : Function) : void
		{
			_onFail = onFail;
			_onSuccess = onSuccess;
			amfBridge.followUser(_sessionID, userID, onGeneralSuccess, onGeneralFail);
		}
	}
}
