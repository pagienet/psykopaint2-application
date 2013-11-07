package net.psykosoft.psykopaint2.base.remote
{
	import flash.utils.ByteArray;

	public class PsykoSocketPacket
	{
		private static var _nextPacketID:uint = 0;
		private static var _nextBlockID:uint = 0;
		
		public static var MAX_PACKET_DATA_SIZE:uint = 1024;
		
		public static function splitByteArrayToPackets( data:ByteArray ):Vector.<PsykoSocketPacket>
		{
			var result:Vector.<PsykoSocketPacket> = new Vector.<PsykoSocketPacket>();
			var totalSize:int = data.length;
			var totalPackages:int = Math.ceil(totalSize / MAX_PACKET_DATA_SIZE);
			data.position = 0;
			for ( var i:int = 0; i < totalPackages; i++ )
			{
				var packet:PsykoSocketPacket = new PsykoSocketPacket();
				packet.id = _nextPacketID++;
				packet.offset = MAX_PACKET_DATA_SIZE * i;
				packet.totalSize = totalSize;
				packet.totalPackages = totalPackages;
				packet.blockID = _nextBlockID;
				packet.data = new ByteArray();
				packet.data.writeUnsignedInt(packet.id);
				packet.data.writeUnsignedInt(_nextBlockID);
				packet.data.writeUnsignedInt(totalSize);
				packet.data.writeUnsignedInt(totalPackages);
				packet.data.writeUnsignedInt(packet.offset);
				packet.data.writeBytes(data,packet.offset,Math.min(totalSize - packet.offset, MAX_PACKET_DATA_SIZE ));
				result.push(packet);
			}
			_nextBlockID++;
			return result;
		}
		
		public var id:uint;
		public var blockID:uint;
		public var data:ByteArray;
		public var offset:int;
		public var totalPackages:int;
		public var totalSize:int;
		public var lastSendAttempt:int;
		public var sendAttempts:int;
		
		public function PsykoSocketPacket()
		{
		}
		
		public function getObject():ByteArray
		{
			var ba:ByteArray = new ByteArray();
			ba.writeObject({data:data,totalPackages:totalPackages,offset:offset,id:id});
			return ba;
		}
	}
}