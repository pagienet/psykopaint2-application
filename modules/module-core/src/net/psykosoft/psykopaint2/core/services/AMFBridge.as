package net.psykosoft.psykopaint2.core.services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;

	public class AMFBridge
	{
		[Inject]
		public var notifyAMFConnectionFailed : NotifyAMFConnectionFailed;

		private var _connection : NetConnection;
		private var _connectionAttempts : int;

		public function AMFBridge()
		{

		}

		public function connect() : void
		{
			if (_connection) throw "Connection already exists";
			_connectionAttempts = 0;
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_connection.connect(CoreSettings.ACTIVE_GATEWAY_URL);
			// test connection upfront, not sure if it's really necessary
//			_connection.call("Main/ping", new Responder(onPingSuccess, onPingError), [1]);
		}

		private function onPingSuccess(result : Object) : void
		{

		}

		private function onPingError(result : Object) : void
		{
			trace ("Error pinging");
		}

		private function onAsyncError(event : AsyncErrorEvent) : void
		{
			notifyAMFConnectionFailed.dispatch(AMFErrorCode.CONNECTION_ASYNC_ERROR);
		}

		private function onIOError(event : IOErrorEvent) : void
		{
			notifyAMFConnectionFailed.dispatch(AMFErrorCode.CONNECTION_IO_ERROR);
		}

		private function onNetStatus(event : NetStatusEvent) : void
		{
			if (event.info.code == "NetConnection.Call.Failed") {
				trace("Failed to log in");

				//TRY TO CONNECT AGAIN

				if (_connectionAttempts < 3) {
					trace("Retrying...");
					_connection.connect(CoreSettings.ACTIVE_GATEWAY_URL);
					_connectionAttempts++;
				}
				else {
					trace("Giving up...");
					notifyAMFConnectionFailed.dispatch(AMFErrorCode.CONNECTION_REFUSED);
				}
			}
			else if (event.info.code != "NetConnection.Connect.Success")
				notifyAMFConnectionFailed.dispatch(AMFErrorCode.UNKNOWN_RESPONSE);
		}

		private function onSecurityError(event : SecurityErrorEvent) : void
		{
			notifyAMFConnectionFailed.dispatch(AMFErrorCode.CONNECTION_SECURITY_ERROR);
		}

		private function removeListeners() : void
		{
			_connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}

		public function getUserImages(userID : uint, index : uint, amount : uint, onSuccess : Function, onFail : Function)
		{
			_connection.call("Main/getUserPaintings", new Responder(onSuccess, onFail), [userID, index, amount]);
		}

		public function getFollowedUserImages(selfUserID : uint, index : uint, amount : uint, onSuccess : Function, onFail : Function)
		{
			_connection.call("Main/getFollowedUsersPaintings", new Responder(onSuccess, onFail), [selfUserID, index, amount]);
		}

		public function getMostLovedImages(index : int, amount : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getMostFavoritedPaintings", new Responder(onSuccess, onFail), [index, amount]);
		}

		public function getMostRecentPaintings(index : int, amount : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getLastPaintings", new Responder(onSuccess, onFail), [index, amount]);
		}
	}
}
