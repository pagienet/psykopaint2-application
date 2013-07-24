package net.psykosoft.psykopaint2.core.managers.rendering
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class SnapshotPromise extends EventDispatcher
	{
		public static const PROMISE_FULFILLED : String = "promiseFulfilled";

		private var _texture : RefCountedTexture;

		public function SnapshotPromise()
		{
		}

		public function get texture() : RefCountedTexture
		{
			return _texture;
		}

		public function set texture(value : RefCountedTexture) : void
		{
			_texture = value;
			value.addRefCount();
			dispatchEvent(new Event(PROMISE_FULFILLED));
		}

		public function dispose():void {
			_texture.dispose();
		}
	}
}
