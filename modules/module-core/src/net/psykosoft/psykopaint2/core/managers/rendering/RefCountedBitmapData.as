package net.psykosoft.psykopaint2.core.managers.rendering
{
	import flash.display.BitmapData;

	public class RefCountedBitmapData extends BitmapData
	{
		private var _refCount : int;

		public function RefCountedBitmapData(width : int, height : int, transparent : Boolean = true, fillColor : uint = 0)
		{
			super(width, height, transparent, fillColor);
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
