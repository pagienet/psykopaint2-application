package net.psykosoft.psykopaint2.base.utils
{

	public class BsStackUtil
	{
		private var _stack:Vector.<Number>;

		public var count:uint = 10;
		private var _newestIndex : int = -1;
		private var _numElements : int;

		public function BsStackUtil() {
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

		public function getAverageValue():Number {
			var value:Number = 0;

			for( var i:uint = 0; i < _numElements; ++i )
				value += _stack[i];

			return value / _numElements;
		}
	}
}
