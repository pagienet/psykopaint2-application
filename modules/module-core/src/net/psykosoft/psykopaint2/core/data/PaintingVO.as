package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;

	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	public class PaintingVO
	{
		//Mario: I strongly recommend to also add a "save format versionID" 
		//since the time might come when we will want to store more but still
		//want to open old files
		
		public var colorImageARGB:ByteArray;
		public var heightmapImageARGB:ByteArray;
		public var sourceImageARGB:ByteArray;
		public var id:String;
		public var width:int;
		public var height:int;
		public var lastSavedOnDateMs:Number;
		public var fileVersion:String;

		public function PaintingVO() {
			super();
		}

		public function toString():String {
			return "PaintingVO --------- \n" +
					"fileVersion: " + fileVersion + "\n" +
					"id: " + id + "\n" +
					"lastSavedOnDateMs: " + lastSavedOnDateMs + "\n";
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
			encodeImage( bytes, colorImageARGB, width, height );
			encodeImage( bytes, heightmapImageARGB, width, height );
			encodeImage( bytes, sourceImageARGB, width, height );

			return bytes;
		}

		private function encodeImage( bytes:ByteArray, imageBytes:ByteArray , width : int, height : int):void {
			imageBytes.length = width*height*4;
			//Mario question: why is every image zipped separately instead of zipping the entire bytearray at the end?
			imageBytes.compress( CompressionAlgorithm.ZLIB );
			bytes.writeInt( imageBytes.length );
			bytes.writeBytes( imageBytes );
		}

		// ---------------------------------------------------------------------
		// De-serialization.
		// ---------------------------------------------------------------------

		public function deSerialize( bytes:ByteArray ):Boolean {

			// Check version first.
			fileVersion = bytes.readUTF();
			if( fileVersion != CoreSettings.PAINTING_FILE_VERSION ) {
				trace( "PaintingVO deSerialize() - ***WARNING*** Unable to interpret loaded painting file, version is [" + fileVersion + "] and app is using version [" + CoreSettings.PAINTING_FILE_VERSION + "]" );
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
			var numBytes:int = bytes.readInt();
			var imageBytes:ByteArray = new ByteArray();
			bytes.readBytes( imageBytes, 0, numBytes );
			imageBytes.uncompress( CompressionAlgorithm.ZLIB );
			return imageBytes;
		}
	}
}
