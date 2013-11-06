package net.psykosoft.psykopaint2.base.remote
{
	import flash.utils.ByteArray;

	public class PsykoSocketPacket
	{
		private static var _nextID:uint = 0;
		
		public static var MAX_PACKET_DATA_SIZE:uint = 1024;
		
		public static function splitByteArrayToPackets( data:ByteArray ):Vector.<PsykoSocketPacket>
		{
			var result:Vector.<PsykoSocketPacket> = new Vector.<PsykoSocketPacket>();
			var totalSize:int = data.length;
			var totalPackages:int = Math.ceil(totalSize / MAX_PACKET_DATA_SIZE);
			for ( var i:int = 0; i < totalPackages; i++ )
			{
				var packet:PsykoSocketPacket = new PsykoSocketPacket();
				packet.id = _nextID++;
				packet.offset = MAX_PACKET_DATA_SIZE * i;
				packet.totalSize = totalSize;
				packet.totalPackages = totalPackages;
				packet.data = new ByteArray();
				packet.data.writeUnsignedInt(0xc0ffee);
				packet.data.writeUnsignedInt(0xf00d);
				packet.data.writeUnsignedInt(packet.id );
				packet.data.writeUnsignedInt(totalSize);
				packet.data.writeUnsignedInt(totalPackages);
				packet.data.writeBytes(data,packet.offset,MAX_PACKET_DATA_SIZE);
				result.push(packet);
			}
			
			return result;
		}
		
		public var id:uint;
		public var data:ByteArray;
		public var offset:int;
		public var totalPackages:int;
		public var totalSize:int;
		public var lastSendAttempt:int;
		public var sendAttempts:int;
		
		public function PsykoSocketPacket()
		{
		}
		
	}
}