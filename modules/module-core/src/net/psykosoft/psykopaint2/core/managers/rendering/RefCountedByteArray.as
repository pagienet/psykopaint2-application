package net.psykosoft.psykopaint2.core.managers.rendering
{
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class RefCountedByteArray extends TrackedByteArray
	{
		private var _refCount : int = 1;

		public function RefCountedByteArray()
		{
			super();
		}

		override public function dispose() : void
		{
			if (--_refCount == 0)
				super.dispose();

			if (_refCount < 0)
				throw "More usages removed than exist!";
		}

		public function addRefCount() : void
		{
			++_refCount;
		}

		// call this to pass on a reference to the texture that will be passed on to another piece of code that should be allowed to dispose of it separately
		public function newReference() : RefCountedByteArray
		{
			++_refCount;
			return this;
		}
	}
}
