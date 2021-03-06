package net.psykosoft.psykopaint2.core.services
{
	import com.adobe.crypto.MD5;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.UserRegistrationVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;

	public class AMFBridge
	{
		[Inject]
		public var notifyAMFConnectionFailed : NotifyAMFConnectionFailed;

		private var _connection : NetConnection;

		public function AMFBridge()
		{

		}

		public function connect() : void
		{
			if (_connection) throw "Connection already exists";
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

			_connection.connect(CoreSettings.ACTIVE_GATEWAY_URL);
			// test connection upfront, not sure if it's really necessary
//			_connection.call("Main/ping", new Responder(onPingSuccess, onPingError), [1]);
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
				trace("Failed to connect to service");
				notifyAMFConnectionFailed.dispatch(AMFErrorCode.CONNECTION_REFUSED);
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

		public function getUserImages(sessionID : String, userID : uint, index : uint, amount : uint, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getUserPaintings", new Responder(onSuccess, onFail), sessionID, userID, index, amount);
		}

		public function getFollowedUserImages(sessionID : String, index : uint, amount : uint, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getFollowedUsersPaintings", new Responder(onSuccess, onFail), sessionID, index, amount);
		}

		public function getMostLovedImages(sessionID : String, index : int, amount : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getMostFavoritedPaintings", new Responder(onSuccess, onFail), sessionID, index, amount);
		}

		public function getMostRecentPaintings(sessionID : String, index : int, amount : int, onSuccess : Function, onFail : Function) : void
		{
			sessionID ||= "";
			_connection.call("Main/getLastPaintings", new Responder(onSuccess, onFail), sessionID, index, amount);
		}

		public function logIn(email : String, password : String, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/loginUser", new Responder(onSuccess, onFail), email, hashPassword(email, password));
		}

		public function registerAndLogIn(userRegistrationVO : UserRegistrationVO, onSuccess : Function, onFail : Function) : void
		{
			_connection.call(	"Main/createUser", new Responder(onSuccess, onFail),
								userRegistrationVO.facebookID,
								userRegistrationVO.email,
								hashPassword(userRegistrationVO.email, userRegistrationVO.password),
								userRegistrationVO.firstName,
								userRegistrationVO.lastName
							);
		}

		public function requestResetPassword( email:String, onSuccess:Function, onFail:Function ):void {
			_connection.call( "Main/passwordReset", new Responder( onSuccess, onFail ), email );
		}

		public function logOut(sessionID : String, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/logout", new Responder(onSuccess, onFail), sessionID);
		}

		public function publishPainting(sessionID : String, paintingDataVO : PaintingDataVO, compositeData : ByteArray, hasSourceImage : Boolean, onSuccess : Function, onFail : Function) : void
		{
			// TODO: pass in a frameID
			_connection.call("Main/publishPainting", new Responder(onSuccess, onFail),
					sessionID,
					0,
					int(hasSourceImage),
					paintingDataVO.normalSpecularData,
					paintingDataVO.colorData,
					paintingDataVO.sourceImageData,
					compositeData);
		}

		public function requestPasswordReset(email : String, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/passwordReset", new Responder(onSuccess, onFail), email);
		}

		public function addCommentToPainting(sessionID : String, paintingID : int, text : String, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/addCommentToPainting", new Responder(onSuccess, onFail), sessionID, paintingID, text);
		}
		
		public function removePainting(sessionID : String, paintingID : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/removePainting", new Responder(onSuccess, onFail), sessionID, paintingID);
		}

		public function favoritePainting(sessionID : String, paintingID : int, onSuccess : Function, onFail : Function) : void
		{
			trace(this+""+arguments.callee);
			_connection.call("Main/addUserFavoritePainting", new Responder(onSuccess, onFail), sessionID, paintingID);
		}

		public function unfavoritePainting(sessionID : String, paintingID : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/removeUserFavoritePainting", new Responder(onSuccess, onFail), sessionID, paintingID);
		}

		private function hashPassword(email : String, password : String) : String
		{
			var hashed:String = MD5.hash(email + MD5.hash(password));
			trace("AMFBridge - hashed pass: " + hashed);
			// KEEP COMMENTED - temporarily overcoming the endianness problem
			// to be able to login on the ipad.
//			hashed = "b553c0f171522a15991225e6030695cc"; // Logs li@psykosoft.net in.
			return hashed;
		}

		public function setProfileImage(sessionId:String, imageBytes:ByteArray, thumbnailBytes:ByteArray) : void
		{
			_connection.call( "Main/setProfileImage", null, sessionId, imageBytes, thumbnailBytes );
		}

		public function updateSubscription(sessionID:String, type:int, subscribe:Boolean, onSuccess:Function, onFail:Function):void
		{
			_connection.call( "Main/subscribeNotification", new Responder(onSuccess, onFail), sessionID, type, subscribe );
		}

		public function followUser(sessionID : String, userID : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/followUser", new Responder(onSuccess, onFail), sessionID, userID);
		}

		public function unfollowUser(sessionID : String, userID : int, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/unfollowUser", new Responder(onSuccess, onFail), sessionID, userID);
		}

		public function getFollowedUsers(sessionID : String, onSuccess : Function, onFail : Function) : void
		{
			_connection.call("Main/getFollowingUsers", new Responder(onSuccess, onFail), sessionID);
		}
	}
}
