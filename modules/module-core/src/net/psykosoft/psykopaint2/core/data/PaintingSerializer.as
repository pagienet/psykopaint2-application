package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;

	public class PaintingSerializer
	{
		public static const PAINTING_FILE_VERSION:String = "9";
		public static const PAINTING_FILE_EXTENSION:String = ".ppp2";

		private var _onDeSerializationCompleteCallback:Function;
		private var _bytes:ByteArray;
		private var _vo:PaintingVO;

		public function PaintingSerializer() {
			super();
		}

		// ---------------------------------------------------------------------
		// Serialize.
		// ---------------------------------------------------------------------

		public function serializePaintingVO( vo:PaintingVO ):ByteArray {

			// TODO: cache bytes and use dirty flag to recalculate

			var bytes:ByteArray = new ByteArray();

			// Thumbnail bmd -> jpg.
			var thumbnailJpgBytes:ByteArray = vo.thumbnail.encode( vo.thumbnail.rect, new JPEGEncoderOptions() );
			var thumbnailBytesLength:uint = thumbnailJpgBytes.length;

			// Write exposed single value data.
			bytes.writeUTF( vo.fileVersion );
			bytes.writeUTF( vo.id );
			bytes.writeInt( vo.width );
			bytes.writeInt( vo.height );
			bytes.writeFloat( vo.lastSavedOnDateMs );
			bytes.writeUnsignedInt( thumbnailBytesLength );

			// Write images.
			bytes.writeBytes( thumbnailJpgBytes );
			var len:int = vo.width * vo.height * 4;
			bytes.writeBytes( vo.colorImageBGRA, 0, len );
			bytes.writeBytes( vo.heightmapImageBGRA, 0, len );
			bytes.writeBytes( vo.sourceImageARGB, 0, len );

			// TODO: re-enable compression
			/*
			 * It's too slow. Try to find an alternative way to compress, perhaps natively or asynchronically.
			 * Compressed file sizes are around 1mb-3mb, uncompressed 9mb-10mb.
			 * Default compression time is around 3500ms.
			 * */
//			bytes.compress();

			return bytes;

		}

		// ---------------------------------------------------------------------
		// De-Serialize.
		// ---------------------------------------------------------------------

		public function deSerializePaintingVO( bytes:ByteArray, vo:PaintingVO, onComplete:Function ):void {

			_onDeSerializationCompleteCallback = onComplete;
			_bytes = bytes;
			_vo = vo;

//			bytes.uncompress();

			// Check version first.
			vo.fileVersion = bytes.readUTF();
			if( vo.fileVersion != PAINTING_FILE_VERSION ) {
				trace( "PaintingVO deSerialize() - ***WARNING*** Unable to interpret loaded painting file, version is [" + vo.fileVersion + "] and app is using version [" + PAINTING_FILE_VERSION + "]" );
				return;
			}

			// Read and set exposed single value data.
			vo.id = bytes.readUTF();
			vo.width = bytes.readInt();
			vo.height = bytes.readInt();
			vo.lastSavedOnDateMs = bytes.readFloat();
			var thumbnailBytesLength:uint = bytes.readUnsignedInt();

			// Read and decode thumb.
			decodeJpg( bytes, thumbnailBytesLength, deSerializeStep2 );
		}

		private function deSerializeStep2( thumbBmd:BitmapData ):void {

			// Set read thumb.
			_vo.thumbnail = thumbBmd;

			// Read painting surfaces.
			_vo.colorImageBGRA = decodeImage( _bytes, _vo.width, _vo.height );
			_vo.heightmapImageBGRA = decodeImage( _bytes, _vo.width, _vo.height );
			_vo.sourceImageARGB = decodeImage( _bytes, _vo.width, _vo.height );

			_onDeSerializationCompleteCallback();
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function decodeImage( bytes:ByteArray, width:uint, height:Number ):ByteArray {
			var numBytes:int = width * height * 4;
			var imageBytes:ByteArray = new ByteArray();
			bytes.readBytes( imageBytes, 0, numBytes );
			return imageBytes;
		}

		private function decodeJpg( bytes:ByteArray, numBytes:int, onComplete:Function ):void {
			// Extract png bytes.
			var jpgBytesOnly:ByteArray = new ByteArray();
			bytes.readBytes( jpgBytesOnly, 0, numBytes );
			// Decode.
			var decoder:PngDecodeUtil = new PngDecodeUtil();
			decoder.decode( jpgBytesOnly, onComplete );
		}
	}
}
