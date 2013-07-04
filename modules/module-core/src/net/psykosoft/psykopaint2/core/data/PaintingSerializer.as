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
		public static const SURFACE_PREVIEW_SHRINK_FACTOR:Number = 4; // powers of 2, integers > 1

		private var _onDeSerializePaintingVoInfoCompleteCallback:Function;
		private var _vo:PaintingInfoVO;
		private var _bytes:ByteArray;

		public function PaintingSerializer() {
			super();
		}

		// ---------------------------------------------------------------------
		// Serialize.
		// ---------------------------------------------------------------------

		public function serializePaintingVoInfo( vo:PaintingInfoVO ):ByteArray {

			var bytes:ByteArray = new ByteArray();

			// TODO: serialize low res bgras

			// Thumbnail bmd -> jpg.
			var thumbnailJpgBytes:ByteArray = vo.thumbnail.encode( vo.thumbnail.rect, new JPEGEncoderOptions() );
			var thumbnailBytesLength:uint = thumbnailJpgBytes.length;

			// Write exposed single value data.
			bytes.writeUTF( vo.fileVersion );
			bytes.writeUTF( vo.id );
			bytes.writeInt( vo.previewWidth );
			bytes.writeInt( vo.previewHeight );
			bytes.writeFloat( vo.lastSavedOnDateMs );
			bytes.writeUnsignedInt( thumbnailBytesLength );

			// Write images.
			bytes.writeBytes( thumbnailJpgBytes );
			var len:int = vo.previewWidth * vo.previewHeight * 4;
			bytes.writeBytes( vo.colorSurfacePreview, 0, len );
			bytes.writeBytes( vo.normalsSurfacePreview, 0, len );

			compressBytes( bytes );

			bytes.position = 0;
			return bytes;
		}

		public function serializePaintingVoData( vo:PaintingDataVO ):ByteArray {

			var bytes:ByteArray = new ByteArray();

			// Write dimensions.
			bytes.writeInt( vo.fullWidth );
			bytes.writeInt( vo.fullHeight );

			// Write surfaces.
			var len:uint = vo.fullWidth * vo.fullHeight * 4;
			bytes.writeBytes( vo.surfaces[ 0 ], 0, len );
			bytes.writeBytes( vo.surfaces[ 1 ], 0, len );
			bytes.writeBytes( vo.surfaces[ 2 ], 0, len );

			compressBytes( bytes );

			bytes.position = 0;
			return bytes;
		}

		// ---------------------------------------------------------------------
		// De-Serialize.
		// ---------------------------------------------------------------------

		public function deSerializePaintingVoInfoAsync( bytes:ByteArray, vo:PaintingInfoVO, onComplete:Function ):void {

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
			vo.previewWidth = bytes.readInt();
			vo.previewHeight = bytes.readInt();
			vo.lastSavedOnDateMs = bytes.readFloat();
			var thumbnailBytesLength:uint = bytes.readUnsignedInt();

			// Read and decode thumb.
			decodeJpg( bytes, thumbnailBytesLength, deSerializePaintingVoInfoStep2 );
		}

		private function deSerializePaintingVoInfoStep2( thumbBmd:BitmapData ):void {

			// Set thumb.
			_vo.thumbnail = thumbBmd;

			// Read low res surfaces.
			_vo.colorSurfacePreview = decodeImage( _bytes, _vo.previewWidth, _vo.previewWidth );
			_vo.normalsSurfacePreview = decodeImage( _bytes, _vo.previewHeight, _vo.previewHeight );

			_onDeSerializePaintingVoInfoCompleteCallback();
		}

		public function deSerializePaintingVoData( bytes:ByteArray, vo:PaintingDataVO ):void {

			decompressBytes( bytes );

			// Read dimensions.
			vo.fullWidth = bytes.readInt();
			vo.fullHeight = bytes.readInt();

			// Read painting surfaces.
			vo.surfaces = Vector.<ByteArray>( [
				decodeImage( bytes, vo.fullWidth, vo.fullHeight ),
				decodeImage( bytes, vo.fullWidth, vo.fullHeight ),
				decodeImage( bytes, vo.fullWidth, vo.fullHeight )
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
