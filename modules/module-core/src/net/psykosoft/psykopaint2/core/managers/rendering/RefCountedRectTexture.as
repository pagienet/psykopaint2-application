package net.psykosoft.psykopaint2.core.managers.rendering
{
	import flash.display3D.textures.RectangleTexture;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedRectTexture;

	public class RefCountedRectTexture extends TrackedRectTexture
	{
		private var _refCount : int;

		public function RefCountedRectTexture(texture : RectangleTexture)
		{
			super(texture);
		}

// call this to pass on a reference to the texture that will be passed on to another piece of code that should be allowed to dispose of it separately
		public function newReference() : RefCountedRectTexture
		{
			++_refCount;
			return this;
		}

		override public function dispose() : void
		{
			if (--_refCount == 0)
				super.dispose();
		}

		public function addRefCount() : void
		{
			++_refCount;
		}
	}
}
