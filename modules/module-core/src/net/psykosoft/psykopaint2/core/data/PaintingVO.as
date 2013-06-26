package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;

	public class PaintingVO
	{
		public var colorImageARGB:ByteArray;
		public var heightmapImageARGB:ByteArray;
		public var sourceImageARGB:ByteArray;
		public var id:String;
		public var width:int;
		public var height:int;
		public var lastSavedOnDateMs:int;

		public function PaintingVO() {
			super();
		}

		public function toString():String {
			return "PaintingVO --------- \n" +
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
			bytes.writeUTF( id );
			bytes.writeInt( width );
			bytes.writeInt( height );
			bytes.writeInt( lastSavedOnDateMs );

			// Write images.
			encodeImage( bytes, colorImageARGB );
			encodeImage( bytes, heightmapImageARGB );
			encodeImage( bytes, sourceImageARGB );

			return bytes;
		}

		private function encodeImage( bytes:ByteArray, imageBytes:ByteArray ):void {
			imageBytes.compress( CompressionAlgorithm.ZLIB );
			bytes.writeInt( imageBytes.length );
			bytes.writeBytes( imageBytes );
		}

		// ---------------------------------------------------------------------
		// De-serialization.
		// ---------------------------------------------------------------------

		public function deSerialize( bytes:ByteArray ):void {

			// Read and set exposed single value data.
			id = bytes.readUTF();
			width = bytes.readInt();
			height = bytes.readInt();
			lastSavedOnDateMs = bytes.readInt();

			// Read images.
			colorImageARGB = decodeImage( bytes );
			heightmapImageARGB = decodeImage( bytes );
			sourceImageARGB = decodeImage( bytes );
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
