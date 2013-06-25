package net.psykosoft.psykopaint2.core.data
{

	import by.blooddy.crypto.image.PNG24Encoder;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.PngDecodeUtil;

	public class PaintingVO
	{
		public var diffuseImage:BitmapData;
		public var heightmapImage:BitmapData;
		public var compositeImage:BitmapData;
		public var id:String;

		public function PaintingVO() {
			super();
		}

		// ---------------------------------------------------------------------
		// Serialization.
		// ---------------------------------------------------------------------

		private var _deSerializeBytes:ByteArray;
		private var _onDeSerializationCompleteCallback:Function;

		public function serialize():ByteArray {

			// TODO: cache bytes and use dirty flag to recalculate

			var bytes:ByteArray = new ByteArray();

			// Bmd -> png.
			var diffusePng:ByteArray = PNG24Encoder.encode( diffuseImage );
			var heightmapPng:ByteArray = PNG24Encoder.encode( heightmapImage );
			var compositePng:ByteArray = PNG24Encoder.encode( compositeImage );

			// Write exposed string data.
			bytes.writeUTF( id );

			// Write pngs, before each, their size in bytes.
			bytes.writeInt( diffusePng.length );
			bytes.writeBytes( diffusePng );
			bytes.writeInt( heightmapPng.length );
			bytes.writeBytes( heightmapPng );
			bytes.writeInt( compositePng.length );
			bytes.writeBytes( compositePng );

			return bytes;
		}

		public function deSerialize( bytes:ByteArray, onComplete:Function ):void {

			_deSerializeBytes = bytes;
			_onDeSerializationCompleteCallback = onComplete;

			// Read and set exposed string data.
			id = bytes.readUTF();

			// Start png decoding sequence.
			var diffusePngNumBytes:int = _deSerializeBytes.readInt();
			decodePng( _deSerializeBytes, diffusePngNumBytes, onDiffuseImageRead );

		}

		private function onDiffuseImageRead( bmd:BitmapData ):void {
			diffuseImage = bmd;
			// Next png.
			var heightmapPngNumBytes:int = _deSerializeBytes.readInt();
			decodePng( _deSerializeBytes, heightmapPngNumBytes, onHeightmapImageRead );
		}

		private function onHeightmapImageRead( bmd:BitmapData ):void {
			heightmapImage = bmd;
			// Next png.
			var compositePngNumBytes:int = _deSerializeBytes.readInt();
			decodePng( _deSerializeBytes, compositePngNumBytes, onCompositeImageRead );
		}

		private function onCompositeImageRead( bmd:BitmapData ):void {
			compositeImage = bmd;
			// All done.
			_onDeSerializationCompleteCallback();
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function decodePng( bytes:ByteArray, numBytes:int, onComplete:Function ):void {
			// Extract png bytes.
			var pngBytesOnly:ByteArray = new ByteArray();
			bytes.readBytes( pngBytesOnly, 0, numBytes );
			// Decode.
			var decoder:PngDecodeUtil = new PngDecodeUtil();
			decoder.decode( pngBytesOnly, onComplete );
		}
	}
}
