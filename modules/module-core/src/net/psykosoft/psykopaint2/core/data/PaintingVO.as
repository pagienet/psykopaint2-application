package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;

	public class PaintingVO
	{
		public static const PAINTING_FILE_VERSION:String = "2";

		public var colorImageARGB:ByteArray;
		public var heightmapImageARGB:ByteArray;
		public var sourceImageARGB:ByteArray;
		public var id:String;
		public var width:int;
		public var height:int;
		public var lastSavedOnDateMs:Number;
		public var fileVersion:String = PaintingVO.PAINTING_FILE_VERSION;

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

			// Write exposed single value data.
			bytes.writeUTF( fileVersion );
			bytes.writeUTF( id );
			bytes.writeInt( width );
			bytes.writeInt( height );
			bytes.writeFloat( lastSavedOnDateMs );

			// Write images.
			bytes.writeBytes( colorImageARGB );
			bytes.writeBytes( heightmapImageARGB );
			bytes.writeBytes( sourceImageARGB );

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
			colorImageARGB = decodeImage( bytes );
			heightmapImageARGB = decodeImage( bytes );
			sourceImageARGB = decodeImage( bytes );

			// Report ok.
			return true;
		}

		private function decodeImage( bytes:ByteArray ):ByteArray {
			var numBytes:int = width * height * 4;
			var imageBytes:ByteArray = new ByteArray();
			bytes.readBytes( imageBytes, 0, numBytes );
			return imageBytes;
		}
	}
}
