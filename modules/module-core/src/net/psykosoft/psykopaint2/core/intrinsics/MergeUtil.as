package  net.psykosoft.psykopaint2.core.intrinsics
{
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import avm2.intrinsics.memory.li32;
	import avm2.intrinsics.memory.li8;
	import avm2.intrinsics.memory.si32;
	
	public class MergeUtil
	{
		public function MergeUtil()
		{
		}
		
		public static function mergeRGBAData( _mergeBuffer:ByteArray, len:int ) : void
		{
			var aOffset : int = len + 3;
			
			ApplicationDomain.currentDomain.domainMemory  = _mergeBuffer;
			
			for (var i : int = 0; i < len; i += 4, aOffset += 4  ) 
			{
				var rgba:int = li32(i);
				var a:uint = li8(aOffset);
				si32( (a << 24) | ((rgba << 8 ) & 0xff0000) | ((rgba >>> 8 ) & 0xff00) | ((rgba >>> 24 ) & 0xff ), i);
			}
			
			ApplicationDomain.currentDomain.domainMemory  = MemoryManagerIntrinsics.memory;
		}

	}
}