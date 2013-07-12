package net.psykosoft.psykopaint2.core.managers.rendering
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class SnapshotPromise extends EventDispatcher
	{
		public static const PROMISE_FULFILLED : String = "promiseFulfilled";

		private var _scale : Number;
		private var _bitmapData : RefCountedBitmapData;

		public function SnapshotPromise(scale : Number = 1)
		{
			_scale = scale;
		}

		public function get scale() : Number
		{
			return _scale;
		}

		public function get bitmapData() : RefCountedBitmapData
		{
			return _bitmapData;
		}

		public function set bitmapData(value : RefCountedBitmapData) : void
		{
			_bitmapData = value;
			value.addRefCount();
			dispatchEvent(new Event(PROMISE_FULFILLED));
		}
	}
}
