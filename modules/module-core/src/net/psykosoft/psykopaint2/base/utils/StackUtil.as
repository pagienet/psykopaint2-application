package net.psykosoft.psykopaint2.base.utils
{

	public class StackUtil
	{
		private var _stack:Vector.<Number>;
		private var _newestIndex : int = -1;
		private var _numElements : int;

		public var count:uint = 10;

		public function StackUtil() {
			super();
			_stack = new Vector.<Number>();
		}

		public function pushValue( value:Number ):void {
			if(++_newestIndex == count)
				_newestIndex = 0;

			_stack[_newestIndex] = value;

			if (_numElements < count)
				++_numElements;
		}

		public function getAverageDelta():Number {
			if (_newestIndex == -1) return 0;

			var oldestIndex : int = _newestIndex + 1;
			if (oldestIndex == _numElements)
				oldestIndex = 0;

			// total delta is newest - oldest
			return (_stack[_newestIndex] - _stack[oldestIndex]) / (_numElements - 1);
		}

		public function getAverageDeltaDetailed():Number {
			if( _stack.length < 2 ) return 0;
			var value:Number = 0;
			for( var i:uint = 1; i <= _newestIndex; ++i )
				value += _stack[i] - _stack[i-1];
			return value / ( _numElements - 1 );
		}

		public function getAverageValue():Number {
			var value:Number = 0;

			for( var i:uint = 0; i < _numElements; ++i )
				value += _stack[i];

			return value / _numElements;
		}

		public function clear():void {
			_stack = new Vector.<Number>();
			_newestIndex = -1;
			_numElements = 0;
		}

		public function values():Vector.<Number> {
			return _stack;
		}

		public function get newestIndex():int {
			return _newestIndex;
		}
	}
}
