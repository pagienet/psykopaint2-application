package net.psykosoft.psykopaint2.core.drawing.config
{
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	
	public class FastBufferManager
	{
		private static var _fastBuffer:FastBuffer;
		
		static public function getFastBuffer( indexMode:int ):FastBuffer
		{
			if ( _fastBuffer == null )
			{
				_fastBuffer = new FastBuffer(indexMode);
			} else {
				_fastBuffer.indexMode = indexMode;
			}
			return _fastBuffer;
		}
	}
}