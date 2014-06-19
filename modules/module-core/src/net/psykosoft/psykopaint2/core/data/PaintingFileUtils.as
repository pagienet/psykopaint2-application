package net.psykosoft.psykopaint2.core.data
{
	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class PaintingFileUtils
	{
		public static const PAINTING_FILE_VERSION:String = "15";
		public static const PAINTING_INFO_FILE_EXTENSION:String = ".ipp2";
		public static const PAINTING_DATA_FILE_EXTENSION:String = ".dpp2";

		static public function decodeImage(bytes : TrackedByteArray, width : uint, height : Number) : TrackedByteArray
		{
			var numBytes : int = width * height * 4;
			var imageBytes : TrackedByteArray = new TrackedByteArray();
			bytes.readBytes(imageBytes, 0, numBytes);
			return imageBytes;
		}

		static public function decodePNG( bytes:TrackedByteArray, numBytes:int, onComplete:Function ):void {
			// Extract png bytes.
			var pngBytesOnly:TrackedByteArray = new TrackedByteArray();
			bytes.readBytes( pngBytesOnly, 0, numBytes );
			// Decode.
			var decoder:PngDecodeUtil = new PngDecodeUtil();
			decoder.decode( pngBytesOnly, onComplete, true );
		}
		
		static public function readColorPalettes( bytes:TrackedByteArray ):Vector.<Vector.<uint>> {
			
			var l:uint = bytes.readUnsignedInt();
			var palettes:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(l);
			for ( var i:int = 0; i <l; i++ )
			{
				var c:uint =  bytes.readUnsignedInt();
				palettes[i] = new Vector.<uint>(c);
				for ( var j:int = 0; j < c; j++ )
				{
					palettes[i][j] = bytes.readUnsignedInt();
				}
			}
			
			return palettes;
		}
	}
}
