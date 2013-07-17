package net.psykosoft.psykopaint2.core.session
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;

	public class AMFTestSession
	{
		private var _netConnection:NetConnection;
		
		public function AMFTestSession()
		{
			init();
		}
		
		public function init():void
		{
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus );
			_netConnection.connect("http://dev.psykopaint.com/api/amf/");
			_netConnection.call("Main/callMeMaybe", new Responder(handleResult, null));
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			trace("##########################");
			for ( var i:* in event.info )
			{
				trace(i,event.info[i]);
			}
			trace("##########################");
			
		}
		
		private function handleResult(result:Object):void
		{
			trace("##########################");
			for ( var i:* in result )
			{
				trace(i,result[i]);
			}
			trace("##########################");
		}	
	}
}