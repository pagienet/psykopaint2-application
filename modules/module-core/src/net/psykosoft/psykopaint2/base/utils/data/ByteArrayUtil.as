package net.psykosoft.psykopaint2.base.utils.data
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class ByteArrayUtil
	{
		public static function createBlankColorData(width : uint, height : uint, color : uint) : TrackedByteArray
		{
			var len : int = width*height;
			var ba : TrackedByteArray = new TrackedByteArray();
			for (var i : int = 0; i < len; ++i)
				ba.writeUnsignedInt(color);
			ba.position = 0;
			return ba;
		}

		public static function swapIntByteOrder(source : TrackedByteArray) : TrackedByteArray
		{
			var byteArray : TrackedByteArray = new TrackedByteArray();
			byteArray.endian = source.endian;
			swapEndianNess(source);
			source.position = 0;
			var len : uint = source.length/4;
			for (var i : uint = 0; i < len; ++i)
				byteArray.writeUnsignedInt(source.readUnsignedInt());
			swapEndianNess(source);
			return byteArray;
		}

		private static function swapEndianNess(source : TrackedByteArray) : void
		{
			source.endian = source.endian == Endian.LITTLE_ENDIAN ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
		}
	}
}
