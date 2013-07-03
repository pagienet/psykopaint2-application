package net.psykosoft.psykopaint2.core.data
{

	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;

	public class PaintingVO
	{
		public static const DEFAULT_VO_ID:String = "new";
		public static const PAINTING_FILE_VERSION:String = "9";
		public static const PAINTING_FILE_EXTENSION:String = ".ppp2";

		public var thumbnail:BitmapData;
		public var colorImageBGRA:ByteArray;
		public var heightmapImageBGRA:ByteArray;
		public var sourceImageARGB:ByteArray;
		public var id:String;
		public var lastSavedOnDateMs:Number;
		public var fileVersion:String = PaintingVO.PAINTING_FILE_VERSION;

		private var _width:int;
		private var _height:int;
		private var _textureWidth:int;
		private var _textureHeight:int;
		private var _onDeSerializationCompleteCallback:Function;
		private var _bytes:ByteArray;

		public function PaintingVO() {
			super();
		}

		public function toString():String {
			return "PaintingVO - " +
					"fileVersion: " + fileVersion +
					", id: " + id +
					", lastSavedOnDateMs: " + lastSavedOnDateMs;
		}

		// ---------------------------------------------------------------------
		// Serialization.
		// ---------------------------------------------------------------------

		public function serialize():ByteArray {

			// TODO: cache bytes and use dirty flag to recalculate

			var bytes:ByteArray = new ByteArray();

			// Thumbnail bmd -> jpg.
			var thumbnailJpgBytes:ByteArray = thumbnail.encode( thumbnail.rect, new JPEGEncoderOptions() );
			var thumbnailBytesLength:uint = thumbnailJpgBytes.length;
			trace( this, "write jpg num bytes: " + thumbnailBytesLength );

			// Write exposed single value data.
			bytes.writeUTF( fileVersion );
			bytes.writeUTF( id );
			bytes.writeInt( _width );
			bytes.writeInt( _height );
			bytes.writeFloat( lastSavedOnDateMs );
			bytes.writeUnsignedInt( thumbnailBytesLength );

			// Write images.
			bytes.writeBytes( thumbnailJpgBytes );
			var len : int = _width*_height*4;
			bytes.writeBytes( colorImageBGRA, 0, len );
			bytes.writeBytes( heightmapImageBGRA, 0, len );
			bytes.writeBytes( sourceImageARGB, 0, len );

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
		// De-serialization.
		// ---------------------------------------------------------------------

		public function deSerialize( bytes:ByteArray, onComplete:Function ):void {

			_onDeSerializationCompleteCallback = onComplete;
			_bytes = bytes;

//			bytes.uncompress();

			// Check version first.
			// TODO: try/catch on RetrievePaintingSavedDataCommand makes this warning never trace
			fileVersion = bytes.readUTF();
			if( fileVersion != PAINTING_FILE_VERSION ) {
				trace( "PaintingVO deSerialize() - ***WARNING*** Unable to interpret loaded painting file, version is [" + fileVersion + "] and app is using version [" + PAINTING_FILE_VERSION + "]" );
				return;
			}

			// Read and set exposed single value data.
			id = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			lastSavedOnDateMs = bytes.readFloat();
			var thumbnailBytesLength:uint = bytes.readUnsignedInt();
			trace( this, "read jpg num bytes: " + thumbnailBytesLength );

			// Read and decode thumb.
			decodeJpg( bytes, thumbnailBytesLength, deSerializeStep2 );
		}

		private function deSerializeStep2( thumbBmd:BitmapData ):void {

			// Set read thumb.
			thumbnail = thumbBmd;

			// Read painting surfaces.
			colorImageBGRA = decodeImage( _bytes );
			heightmapImageBGRA = decodeImage( _bytes );
			sourceImageARGB = decodeImage( _bytes );

			_onDeSerializationCompleteCallback();
		}

		private function decodeImage( bytes:ByteArray ):ByteArray {
			trace ("[decode]", _width, _height);
			var numBytes:int = _width * _height * 4;
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

		// ---------------------------------------------------------------------
		// Setters and getters.
		// ---------------------------------------------------------------------

		public function get width():int {
			return _width;
		}

		public function set width( value:int ):void {
			_width = value;
			_textureWidth = TextureUtils.getBestPowerOf2( _width );
		}

		public function get height():int {
			return _height;
		}

		public function set height( value:int ):void {
			_height = value;
			_textureHeight = TextureUtils.getBestPowerOf2( _height );
		}

		public function get textureWidth():int {
			return _textureWidth;
		}

		public function get textureHeight():int {
			return _textureHeight;
		}
	}
}
