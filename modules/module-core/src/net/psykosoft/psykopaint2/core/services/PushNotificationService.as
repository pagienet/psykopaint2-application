package net.psykosoft.psykopaint2.core.services
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.RemoteNotificationEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestMethod;
	import flash.notifications.NotificationStyle;
	import flash.notifications.RemoteNotifier;
	import flash.notifications.RemoteNotifierSubscribeOptions;

	public class PushNotificationService
	{
		private static var PROVIDER_HOST_NAME : String = "go.urbanairship.com";
		private static var PROVIDER_TOKEN_URL : String = "https://" + PROVIDER_HOST_NAME + "/api/device_tokens/";
		private static var APP_KEY : String = "IowU3jExSaSB7Qgf6MzptQ";
		private static var APP_SECRET : String = "Fg-KLSLdSg2zxB493hXTSQ";

		private var _remoteNotifier : RemoteNotifier;
		private var _supportsNotifications : Boolean;

		public function PushNotificationService()
		{
			checkSupport();
		}

		public function get supportsNotifications():Boolean
		{
			return _supportsNotifications;
		}

		private function checkSupport():void
		{
			_supportsNotifications = RemoteNotifier.supportedNotificationStyles.length != 0;

			if (_supportsNotifications)
				trace("Notifications are GO!");
			else
				trace("WARNING: Notifications not supported!");
		}

		public function subscribe():void
		{
			if (!_supportsNotifications)
				return;

			_remoteNotifier = new RemoteNotifier();
			_remoteNotifier.addEventListener(RemoteNotificationEvent.TOKEN, onRemoteNotificationToken);
			_remoteNotifier.addEventListener(StatusEvent.STATUS, onStatus);

			var options : RemoteNotifierSubscribeOptions = new RemoteNotifierSubscribeOptions();
			options.notificationStyles = Vector.<String>([ NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND ]);

			_remoteNotifier.subscribe(options);
		}

		private function onStatus(event:StatusEvent):void
		{
			trace("Notification status:\nEvent Level" + event.level +"\nEvent code " + event.code);
		}

		public function unsubscribe() : void
		{
			if (!_supportsNotifications || !_remoteNotifier)
				return;

			_remoteNotifier.removeEventListener(RemoteNotificationEvent.TOKEN, onRemoteNotificationToken);
			_remoteNotifier.removeEventListener(StatusEvent.STATUS, onStatus);
			_remoteNotifier.unsubscribe();
			_remoteNotifier = null;
		}

		private function onRemoteNotificationToken(event:RemoteNotificationEvent):void
		{
			trace ("Push notification token received: " + event.tokenId);
			var urlRequest : URLRequest = new URLRequest(PROVIDER_TOKEN_URL + event.tokenId);

			urlRequest.authenticate = true;
			urlRequest.method = URLRequestMethod.PUT;
			URLRequestDefaults.setLoginCredentialsForHost(PROVIDER_HOST_NAME, APP_KEY, APP_SECRET);

			var loader : URLLoader = new URLLoader();
			loader.load(urlRequest);
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}

		private function onIOError(event:IOErrorEvent):void
		{
			removeListeners(URLLoader(event.target));
			trace ("WARNING: Could not log in to notification provider. Error ID " + event.errorID)
			_supportsNotifications = false;
		}

		private function removeListeners(loader:URLLoader):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}

		private function onLoadComplete(event:Event):void
		{
			removeListeners(URLLoader(event.target));
			trace ("Logged in to notification provider.");
			_remoteNotifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, onNotificationReceived);
		}

		private function onNotificationReceived(event:RemoteNotificationEvent):void
		{
			trace ("Received notification: " + event.data);
		}
	}
}
