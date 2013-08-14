package net.psykosoft.psykopaint2.base.utils.data
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	public class ByteArrayUtil
	{
		public static function createBlankColorData(width : uint, height : uint, color : uint) : RefCountedByteArray
		{
			var len : int = width*height;
			var ba : RefCountedByteArray = new RefCountedByteArray();
			for (var i : int = 0; i < len; ++i)
				ba.writeUnsignedInt(color);
			ba.position = 0;
			return ba;
		}

		public static function fromBitmapData(bitmapData : BitmapData) : RefCountedByteArray
		{
			var source : ByteArray = bitmapData.getPixels(bitmapData.rect);
			var byteArray : RefCountedByteArray = clone(source);
			source.clear();
			return byteArray;
		}

		public static function clone(source : ByteArray) : RefCountedByteArray
		{
			var byteArray : RefCountedByteArray = new RefCountedByteArray();
			source.position = 0;
			byteArray.writeBytes(source, 0, source.length);
			return byteArray;
		}

		public static function swapIntByteOrder(source : ByteArray) : RefCountedByteArray
		{
			var byteArray : RefCountedByteArray = new RefCountedByteArray();
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
