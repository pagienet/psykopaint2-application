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

		public function PaintingVO() {
			super();
		}

		// ---------------------------------------------------------------------
		// Serialization.
		// ---------------------------------------------------------------------

		public function serialize():ByteArray {

			// TODO: cache bytes and use dirty flag to recalculate

			var bytes:ByteArray = new ByteArray();

			// Write exposed string data.
			bytes.writeUTF( id );

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

			// Read and set exposed string data.
			id = bytes.readUTF();

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
