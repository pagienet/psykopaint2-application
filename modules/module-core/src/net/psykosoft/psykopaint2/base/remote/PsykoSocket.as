package net.psykosoft.psykopaint2.base.remote
{
	import flash.desktop.NativeApplication;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import be.aboutme.nativeExtensions.udp.UDPSocket;
	
	public class PsykoSocket
	{
		private static var instance:PsykoSocket;
		private static const pingTime:int = 2000;
		private static var pingPackage:ByteArray;
		private static var pingCount:uint;
		
		private var udpSocket:UDPSocket;
		private var ip:String;
		private var port:uint;
		private var callbacks:Vector.<PsykoSocketCallback>;
		private var bound:Boolean;
		private var deactivated:Boolean;
		private var pingTimeout:int;
		
		public function PsykoSocket(ip:String = "192.168.178.26", port:uint = 1236)
		{
			_init(ip,port);
		}
		
		private function _init(ip:String = "192.168.178.26", port:uint = 1236):void
		{
			
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onNativeAppDeactivated); 
			
			this.ip = ip;
			this.port = port;
			
			callbacks = new Vector.<PsykoSocketCallback>;
			pingPackage = new ByteArray();
			
			reactivate();
		}
		
		
		
		protected function onNativeAppDeactivated(event:Event):void
		{
			if ( udpSocket ) 
			{
				udpSocket.close();
				udpSocket.removeEventListener(DatagramSocketDataEvent.DATA, udpDataHandler);
				udpSocket.removeEventListener(Event.CLOSE, onSocketClosed );
				udpSocket = null;
			}
			deactivated = true;
			bound = false;
			
		}
		
		protected function reactivate():void
		{
			pingCount = 0;
			
			udpSocket = new UDPSocket();
			udpSocket.addEventListener(DatagramSocketDataEvent.DATA, udpDataHandler);
			udpSocket.addEventListener(Event.CLOSE, onSocketClosed );
			try
			{
				udpSocket.bind(port);
				udpSocket.receive();
				deactivated = false;
				bound = true;
				
				pingPackage.writeObject(pingCount);
				clearTimeout( pingTimeout );
				pingTimeout = setTimeout( ping, pingTime );
			} catch ( error:Error )
			{
				trace(error.message);
				udpSocket.close();
				
			}
			
		}
		
		protected function onSocketClosed(event:Event):void
		{
			bound = false;
			try
			{
				udpSocket.bind(port);
				udpSocket.receive();
				bound = true;
			} catch ( error:Error )
			{
				trace(error.message);
				udpSocket.close();
			}
		}
		
		protected function ping():void
		{
			if ( !bound || deactivated )
			{
				reactivate();
			}
			if ( bound )
			{
				pingPackage.length = 0;
				pingCount++;
				pingPackage.writeObject(pingCount);
				try
				{
					udpSocket.send(pingPackage,ip, port);
				} catch ( error:Error )
				{
					trace(error.message);
				}
				clearTimeout( pingTimeout );
				pingTimeout = setTimeout( ping, pingTime );
			}
		}
		
		protected function udpDataHandler(event:DatagramSocketDataEvent):void
		{
			
			if ( event.data is ByteArray )
			{
				try
				{
					var pckg:Object = event.data.readObject();
					var message:XML = new XML( String(pckg.data) );
					if ( message.hasOwnProperty("@target") )
					{
						var targets:Array = String(message.@target).split(";")
						for ( var j:int = 0; j < targets.length; j++ )
						{
							var targetPath:Array = targets[j].split(".");
							for ( var i:int = 0; i < callbacks.length; i++ )
							{
								if ( callbacks[i].isReceipient(targetPath) )
								{
									callbacks[i].callbackMethod.apply( callbacks[i].callbackObject, [message] );
								}
							}
						}
					}
				
			} catch (error:Error )
			{
				trace(error.message);
			}
		}
		}
		
		protected function _sendString( data:String ):void
		{
			
			if (!bound) return;
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(data);
			udpSocket.send(bytes, ip, port);
		}
		
		protected function _sendBytes( data:ByteArray ):void
		{
			if (!bound) return;
			udpSocket.send(data, ip, port);
		}
		
		protected function _sendObject( data:Object ):void
		{
			if (!bound) return;
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(data);
			udpSocket.send(bytes, ip, port);
		}
		
		protected function _addMessageCallback( targetPath:String, callbackObject:Object, callbackMethod:Function ):void
		{
			//TODO: optional check if callback already exists
			callbacks.push( new PsykoSocketCallback(targetPath, callbackObject, callbackMethod ));
			
		}
		
		protected function _removeMessageCallback( targetPath:String, callbackObject:Object, callbackMethod:Function ):void
		{
			for ( var i:int = callbacks.length; --i >-1; )
			{
				if ( callbacks[i].fullTargetPath == targetPath && callbacks[i].callbackObject == callbackObject && callbacks[i].callbackMethod == callbackMethod )
				{
					callbacks.splice(i,1);
				}
			}
			
		}
		
		static public function init( ip:String = "192.168.178.26", port:uint = 1236 ):void
		{
			if (!instance ) 
			{
				instance = new PsykoSocket(ip,port);
			}
		}
		
		static public function sendString( data:String ):void
		{
			if (instance ) 
			{
				instance._sendString( data );
			}
			
		}
		
		static public function sendBytes( data:ByteArray ):void
		{
			if (instance ) 
			{
				instance._sendBytes( data );
			}
			
		}
		
		static public function sendObject( data:Object ):void
		{
			if (instance ) 
			{
				instance._sendObject( data );
			}
			
		}
		
		static public function addMessageCallback( targetPath:String, callbackObject:Object, callbackMethod:Function ):void
		{
			if (instance ) 
			{
				instance._addMessageCallback( targetPath, callbackObject, callbackMethod );
			}
			
		}
		
		static public function removeMessageCallback( targetPath:String, callbackObject:Object, callbackMethod:Function ):void
		{
			if (instance ) 
			{
				instance._removeMessageCallback( targetPath, callbackObject, callbackMethod );
			}
			
		}
		
		static public function set ip( socketIP:String):void
		{
			if (instance ) 
			{
				instance.ip = socketIP;
			}
			
		}
	}
}