package net.psykosoft.psykopaint2.core.data
{

	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;

	public class PaintingVO
	{
		public static const DEFAULT_VO_ID:String = "new";
		public static const PAINTING_FILE_VERSION:String = "3";

		public var colorImageBGRA:ByteArray;
		public var heightmapImageBGRA:ByteArray;
		public var sourceImageARGB:ByteArray;
		public var id:String;
		private var _width:int;
		private var _height:int;
		private var _textureWidth:int;
		private var _textureHeight:int;
		public var lastSavedOnDateMs:Number;
		public var fileVersion:String = PaintingVO.PAINTING_FILE_VERSION;

		public function PaintingVO() {
			super();
		}

		public function get width() : int
		{
			return _width;
		}

		public function set width(value : int) : void
		{
			_width = value;
			_textureWidth = TextureUtils.getBestPowerOf2(_width);
		}

		public function get height() : int
		{
			return _height;
		}

		public function set height(value : int) : void
		{
			_height = value;
			_textureHeight = TextureUtils.getBestPowerOf2(_height);
		}

		public function get textureWidth() : int
		{
			return _textureWidth;
		}

		public function get textureHeight() : int
		{
			return _textureHeight;
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

			trace ("[serialize]", _width, _height);

			// Write exposed single value data.
			bytes.writeUTF( fileVersion );
			bytes.writeUTF( id );
			bytes.writeInt( _width );
			bytes.writeInt( _height );
			bytes.writeFloat( lastSavedOnDateMs );

			// Write images.
			var len : int = _width*_height*4;
			bytes.writeBytes( colorImageBGRA, 0, len );
			bytes.writeBytes( heightmapImageBGRA, 0, len );
			bytes.writeBytes( sourceImageARGB, 0, len );

			bytes.compress();

			return bytes;
		}

		// ---------------------------------------------------------------------
		// De-serialization.
		// ---------------------------------------------------------------------

		public function deSerialize( bytes:ByteArray ):Boolean {
			bytes.uncompress();

			// Check version first.
			// TODO: try/catch on RetrievePaintingSavedDataCommand makes this warning never trace
			fileVersion = bytes.readUTF();
			if( fileVersion != PAINTING_FILE_VERSION ) {
				trace( "PaintingVO deSerialize() - ***WARNING*** Unable to interpret loaded painting file, version is [" + fileVersion + "] and app is using version [" + PAINTING_FILE_VERSION + "]" );
				return false;
			}

			// Read and set exposed single value data.
			id = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			lastSavedOnDateMs = bytes.readFloat();

			// Read images.
			colorImageBGRA = decodeImage( bytes );
			heightmapImageBGRA = decodeImage( bytes );
			sourceImageARGB = decodeImage( bytes );

			// Report ok.
			return true;
		}

		private function decodeImage( bytes:ByteArray ):ByteArray {
			trace ("[decode]", _width, _height);
			var numBytes:int = _width * _height * 4;
			var imageBytes:ByteArray = new ByteArray();
			bytes.readBytes( imageBytes, 0, numBytes );
			return imageBytes;
		}
	}
}
