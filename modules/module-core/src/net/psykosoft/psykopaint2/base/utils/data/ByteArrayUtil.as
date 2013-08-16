package net.psykosoft.psykopaint2.base.utils.data
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class ByteArrayUtil
	{
		public static function createBlankColorData(width : uint, height : uint, color : uint) : ByteArray
		{
			var len : int = width*height;
			var ba : ByteArray = new ByteArray();
			for (var i : int = 0; i < len; ++i)
				ba.writeUnsignedInt(color);
			ba.position = 0;
			return ba;
		}

		public static function swapIntByteOrder(source : ByteArray) : ByteArray
		{
			var byteArray : ByteArray = new ByteArray();
			byteArray.endian = source.endian;
			swapEndianNess(source);
			source.position = 0;
			var len : uint = source.length/4;
			for (var i : uint = 0; i < len; ++i)
				byteArray.writeUnsignedInt(source.readUnsignedInt());
			swapEndianNess(source);
			return byteArray;
		}

		private static function swapEndianNess(source : ByteArray) : void
		{
			source.endian = source.endian == Endian.LITTLE_ENDIAN ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
		}
	}
}
