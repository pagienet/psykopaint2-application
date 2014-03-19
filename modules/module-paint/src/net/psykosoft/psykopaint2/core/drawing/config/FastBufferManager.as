package net.psykosoft.psykopaint2.core.drawing.config
{
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	
	public class FastBufferManager
	{
		private static var _fastBuffer:FastBuffer;
		
		static public function getFastBuffer( indexMode:int, indexMethod : Function = null ):FastBuffer
		{
			if ( _fastBuffer == null )
			{
				_fastBuffer = new FastBuffer(indexMode, indexMethod);
			} else {
				_fastBuffer.indexMethod = indexMethod;
				_fastBuffer.indexMode = indexMode;
			}
			return _fastBuffer;
		}
		
		static public function dispose():void
		{
			if ( _fastBuffer )
			{
				_fastBuffer.dispose();
				_fastBuffer = null;
			}
		}
	}
}