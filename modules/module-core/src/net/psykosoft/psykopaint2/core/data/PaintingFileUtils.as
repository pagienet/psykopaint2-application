package net.psykosoft.psykopaint2.core.data
{
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	public class PaintingFileUtils
	{
		public static const PAINTING_FILE_VERSION:String = "12";
		public static const PAINTING_INFO_FILE_EXTENSION:String = ".ipp2";
		public static const PAINTING_DATA_FILE_EXTENSION:String = ".dpp2";

		static public function decodeImage(bytes : ByteArray, width : uint, height : Number) : RefCountedByteArray
		{
			var numBytes : int = width * height * 4;
			var imageBytes : RefCountedByteArray = new RefCountedByteArray();
			bytes.readBytes(imageBytes, 0, numBytes);
			return imageBytes;
		}

		static public function compressData(data : ByteArray) : void
		{
//			bytes.compress();
		}

		static public function uncompressData(data : ByteArray) : void
		{
//			bytes.uncompress();
		}

		static public function decodePNG( bytes:ByteArray, numBytes:int, onComplete:Function ):void {
			// Extract png bytes.
			var pngBytesOnly:RefCountedByteArray = new RefCountedByteArray();
			bytes.readBytes( pngBytesOnly, 0, numBytes );
			// Decode.
			var decoder:PngDecodeUtil = new PngDecodeUtil();
			decoder.decode( pngBytesOnly, onComplete, true );
		}
	}
}
