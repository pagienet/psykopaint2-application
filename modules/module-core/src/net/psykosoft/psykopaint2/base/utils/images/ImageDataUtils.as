package net.psykosoft.psykopaint2.base.utils.images
{
	import avm2.intrinsics.memory.li8;
	import avm2.intrinsics.memory.si8;

	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public class ImageDataUtils
	{
		public static function ARGBtoBGRA(data : ByteArray, len : int, offset : int) : void
		{
			var tmp:ByteArray = ApplicationDomain.currentDomain.domainMemory;
			len += offset;
			ApplicationDomain.currentDomain.domainMemory = data;

			for (var i : int = offset; i < len; i += 4) {
				var offset1 : int = int(i + 1);
				var offset2 : int = int(i + 2);
				var offset3 : int = int(i + 3);
				var a : uint = li8(i);
				var r : uint = li8(offset1);
				var g : uint = li8(offset2);
				var b : uint = li8(offset3);

				si8(b, i);
				si8(g, offset1);
				si8(r, offset2);
				si8(a, offset3);
			}

			ApplicationDomain.currentDomain.domainMemory = tmp;
		}
	}
}
