package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;

	public class PaintingSerializer
	{
		public static const PAINTING_FILE_VERSION:String = "11";
		public static const PAINTING_INFO_FILE_EXTENSION:String = ".ipp2";
		public static const PAINTING_DATA_FILE_EXTENSION:String = ".dpp2";
		// Currently set at 1 because low res surfaces are being saved at full size, when that is fixed, set back to 2!
		public static const SURFACE_PREVIEW_SHRINK_FACTOR:Number = 1;

		private var _onDeSerializePaintingVoInfoCompleteCallback:Function;
		private var _vo:PaintingVO;
		private var _bytes:ByteArray;

		public function PaintingSerializer() {
			super();
		}

		// ---------------------------------------------------------------------
		// Serialize.
		// ---------------------------------------------------------------------

		public function serializePaintingVoInfo( vo:PaintingVO ):ByteArray {

			var bytes:ByteArray = new ByteArray();

			// TODO: serialize low res bgras

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
			bytes.writeBytes( vo.colorSurface, 0, len );
			bytes.writeBytes( vo.normalsSurface, 0, len );

			compressBytes( bytes );

			bytes.position = 0;
			return bytes;
		}

		public function serializePaintingVoData( surfaces:Vector.<ByteArray> ):ByteArray {

			var bytes:ByteArray = new ByteArray();

			// Write surfaces.
			bytes.writeBytes( surfaces[ 0 ], 0, surfaces[ 0 ].length );
			bytes.writeBytes( surfaces[ 1 ], 0, surfaces[ 1 ].length );
			bytes.writeBytes( surfaces[ 2 ], 0, surfaces[ 2 ].length );

			compressBytes( bytes );

			bytes.position = 0;
			return bytes;
		}

		// ---------------------------------------------------------------------
		// De-Serialize.
		// ---------------------------------------------------------------------

		public function deSerializePaintingVoInfoAsync( bytes:ByteArray, vo:PaintingVO, onComplete:Function ):void {

			_onDeSerializePaintingVoInfoCompleteCallback = onComplete;
			_vo = vo;
			_bytes = bytes;

			// TODO: de-serialize low res bgras

			decompressBytes( bytes );

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
			decodeJpg( bytes, thumbnailBytesLength, deSerializePaintingVoInfoStep2 );
		}

		private function deSerializePaintingVoInfoStep2( thumbBmd:BitmapData ):void {

			// Set thumb.
			_vo.thumbnail = thumbBmd;

			// Read low res surfaces.
			_vo.colorSurface = decodeImage( _bytes, _vo.width / SURFACE_PREVIEW_SHRINK_FACTOR, _vo.height / SURFACE_PREVIEW_SHRINK_FACTOR );
			_vo.normalsSurface = decodeImage( _bytes, _vo.width / SURFACE_PREVIEW_SHRINK_FACTOR, _vo.height / SURFACE_PREVIEW_SHRINK_FACTOR );

			_onDeSerializePaintingVoInfoCompleteCallback();
		}

		public function deSerializePaintingVoData( bytes:ByteArray, vo:PaintingVO ):Vector.<ByteArray> {

			decompressBytes( bytes );

			// Read painting surfaces.
			return Vector.<ByteArray>( [
				decodeImage( bytes, vo.width, vo.height ),
				decodeImage( bytes, vo.width, vo.height ),
				decodeImage( bytes, vo.width, vo.height )
			] );
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function compressBytes( bytes:ByteArray ):void {
			// TODO: re-enable compression
			/*
			 * It's too slow. Try to find an alternative way to compress, perhaps natively or asynchronically.
			 * Compressed file sizes are around 1mb-3mb, uncompressed 9mb-10mb.
			 * Default compression time is around 3500ms.
			 * */
//			bytes.compress();
		}

		private function decompressBytes( bytes:ByteArray ):void {
//			bytes.uncompress();
		}

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
