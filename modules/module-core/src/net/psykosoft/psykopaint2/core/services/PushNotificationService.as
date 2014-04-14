package net.psykosoft.psykopaint2.core.services
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.RemoteNotificationEvent;
	import flash.events.StatusEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestMethod;
	import flash.notifications.NotificationStyle;
	import flash.notifications.RemoteNotifier;
	import flash.notifications.RemoteNotifierSubscribeOptions;

	import org.osflash.signals.Signal;

	public class PushNotificationService
	{
		[Inject]
		public var stage : Stage;

		private static const PROVIDER_HOST_NAME : String = "go.urbanairship.com";
		private static const PROVIDER_TOKEN_URL : String = "https://" + PROVIDER_HOST_NAME + "/api/device_tokens/";
		private static const APP_KEY : String = "IowU3jExSaSB7Qgf6MzptQ";
		private static const APP_SECRET : String = "Fg-KLSLdSg2zxB493hXTSQ";

		private var _remoteNotifier : RemoteNotifier;
		private var _supportsNotifications : Boolean;
		private var _subsribeOptions:RemoteNotifierSubscribeOptions;
		private var _sharedObject:SharedObject;

		public const subscriptionFailed : Signal = new Signal();


		public function PushNotificationService()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			_sharedObject = SharedObject.getLocal("notificationSettings");

			_remoteNotifier = new RemoteNotifier();
			_remoteNotifier.addEventListener(RemoteNotificationEvent.TOKEN, onRemoteNotificationToken);
			_remoteNotifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, onNotificationReceived);
			_remoteNotifier.addEventListener(StatusEvent.STATUS, onStatus);
			_subsribeOptions = new RemoteNotifierSubscribeOptions();
			var preferredStyles : Vector.<String> = new Vector.<String>();
			preferredStyles.push(NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND);
			_subsribeOptions.notificationStyles = preferredStyles;

			if (isSubscribed)
				subscribe();

			checkSupport();

			stage.addEventListener(Event.ACTIVATE, onActivate);
		}

		public function get isSubscribed():Boolean
		{
			return _sharedObject.data.isSubscribed;
		}

		// Apple's recommendation: subscribe on activate
		private function onActivate(event:Event):void
		{
			if (isSubscribed)
				subscribe();
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
			_sharedObject.data.isSubscribed = true;
			_sharedObject.flush();
			_remoteNotifier.subscribe(_subsribeOptions);
		}

		public function unsubscribe() : void
		{
			if (!_supportsNotifications || !isSubscribed)
				return;

			_sharedObject.data.isSubscribed = false;
			_sharedObject.flush();

			_remoteNotifier.unsubscribe();
		}

		private function onStatus(event:StatusEvent):void
		{
			trace("Notification status:\nEvent Level" + event.level +"\nEvent code " + event.code);
			_sharedObject.data.isSubscribed = false;
			_sharedObject.flush();
			subscriptionFailed.dispatch();
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
		}

		private function onNotificationReceived(event:RemoteNotificationEvent):void
		{
			trace ("Received notification: ");

			for (var field:String in event.data) {
				trace(field + ":  " + event.data[field]);
			}
		}
	}
}
