package net.psykosoft.psykopaint2.base.utils.data
{
	import flash.utils.ByteArray;

	public class ByteArrayUtil
	{
		public static function createBlankColorData(width : uint, height : uint, color : uint)
		{
			var len : int = width*height;
			var ba : ByteArray = new ByteArray();
			for (var i : int = 0; i < len; ++i)
				ba.writeUnsignedInt(color);
			ba.position = 0;
			return ba;
		}
	}
}
