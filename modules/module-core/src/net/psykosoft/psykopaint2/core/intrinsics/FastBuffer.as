package net.psykosoft.psykopaint2.core.intrinsics
{
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	
	import avm2.intrinsics.memory.sf32;
	import avm2.intrinsics.memory.si16;

	public class FastBuffer
	{
		public static const INDEX_MODE_QUADS:int = 0;
		public static const INDEX_MODE_TRIANGLES:int = 1;
		public static const INDEX_MODE_TRIANGLESTRIP:int = 2;
		public static const INDEX_MODE_CUSTOM:int = 3;	// needs a function to be passed in

		protected var _buffer:ByteArray;
		protected var _baseOffset:int;
		protected var _indexOffset:int;
		protected var _indexMode:int = -1;
		private var _indexMethod:Function;

		private const MAX_VERTEX_COUNT:int = 65535;
		private const MAX_INDEX_COUNT:int = 524286;
		
		public function FastBuffer( indexMode:int = 0, indexMethod : Function = null)
		{
			init( indexMode, indexMethod );
		}

		public function get indexMethod():Function
		{
			return _indexMethod;
		}

		public function set indexMethod(value:Function):void
		{
			_indexMethod = value;
		}

		private function init( indexMode:int = 0, indexMethod : Function = null):void
		{
			
			_baseOffset = MemoryManagerIntrinsics.reserveMemory( MAX_VERTEX_COUNT * 16 * 4 + MAX_INDEX_COUNT * 2);
			_indexOffset = _baseOffset + MAX_VERTEX_COUNT*16*4;
			_buffer = MemoryManagerIntrinsics.memory;
			_indexMethod = indexMethod;
			initIndices(indexMode);
		}
		
		private function initIndices( indexMode:int ):void
		{
			_indexMode = indexMode;
			
			if ( _indexMode == INDEX_MODE_QUADS )
				initQuads(_indexOffset);
			else if ( _indexMode == INDEX_MODE_TRIANGLES )
				initTriangles(_indexOffset);
			else if ( _indexMode == INDEX_MODE_TRIANGLESTRIP )
				initTriangleStrip(_indexOffset);
			else if ( _indexMode == INDEX_MODE_CUSTOM )
				_indexMethod(_indexOffset);
		}

		private function initTriangleStrip(offset:int):void
		{
			var j:uint = 0;
			var i:int = 0;
			while (i < 87381) {
				si16(j, offset);
				offset += 2;
				si16((j + 1), offset);
				offset += 2;
				si16((j + 2), offset);
				offset += 2;
				si16((j + 1), offset);
				offset += 2;
				si16((j + 3), offset);
				offset += 2;
				si16((j + 2), offset);
				offset += 2;
				i++;
				j = ( j + 2 );

			}
		}

		private function initTriangles(offset:int):void
		{
			var j:uint = 0;
			var i:int = 0;
			while (i < 87381) {
				si16(j, offset);
				offset += 2;
				j++;
				i++;
				si16(j, offset);
				offset += 2;
				j++;
				i++;
				si16(j, offset);
				offset += 2;
				j++;
				i++;
			}
		}

		private function initQuads(offset:int):void
		{
			var j:uint = 0;
			var i:int = 0;
			while (i < 87381) {
				si16(j, offset);
				offset += 2;
				si16((j + 1), offset);
				offset += 2;
				si16((j + 2), offset);
				offset += 2;
				si16(j, offset);
				offset += 2;
				si16((j + 2), offset);
				offset += 2;
				si16((j + 3), offset);
				offset += 2;
				i++;
				j += 4;
			}
		}

		public function uploadIndicesToBuffer( indexBuffer:IndexBuffer3D, count:int = 524286):void
		{
			indexBuffer.uploadFromByteArray(_buffer,_indexOffset,0, count);
		}
		
		public function uploadVerticesToBuffer( vertexBuffer:VertexBuffer3D, byteArrayOffset:int, startOffset:int, count:int ):void
		{
			vertexBuffer.uploadFromByteArray(_buffer, _baseOffset + byteArrayOffset,startOffset, count );
		}
		
		public function addFloatsToVertices( data:Vector.<Number>, offset:int ):void
		{
			var i:int =  data.length;
			offset = ( _baseOffset +offset + data.length * 4 );
			while ( i > 0 )
			{
				i--;
				offset -= 4;
				sf32( data[i], offset);
			}
		}
		
		public function addInterleavedFloatsToVertices( data:Vector.<Number>, offset:int, blockCount:int, skipCount:int, dataBlocksToWrite:int = -1 ):void
		{
			var i:int =  0;
			var j:int = 0;
			var l:int = dataBlocksToWrite == -1 ? data.length : dataBlocksToWrite;
			var s:int = skipCount * 4;
			//offset = __cint( offset + (data.length / blockCount) * (blockCount + skipCount) * 4 );
			offset += _baseOffset;
			while ( i < l )
			{
				sf32( data[i], offset);
				offset += 4;
				i++;
				j++;
				if ( j == blockCount )
				{
					offset += s;
					j = 0;
				}
			}
		}
		
		public function addInterleavedFloatByteArrayToVertices( data:ByteArray, offset:int, blockCount:int, skipCount:int ):void
		{
			var blockSize:int = blockCount * 4;
			var skipSize:int = skipCount * 4;
			
			var count:int = data.length / blockSize;
			var dataOffset:int = 0;
			_buffer.position = _baseOffset + offset;
			for ( var i:int = 0; i < count; i++ )
			{
				_buffer.writeBytes( data,dataOffset,blockSize);
				_buffer.position+=skipSize;
				dataOffset += blockSize;
			}
		}
		
		public function get indexMode():int
		{
			return _indexMode;
		}
		
		public function set indexMode( value:int ):void
		{
			if ( value != _indexMode )
			{
				initIndices( value );
			}
		}
		
		public function dispose():void
		{
			_buffer = null;
			_baseOffset = _indexOffset = _indexMode = -1;
			_indexMethod = null;
		}
	}
}