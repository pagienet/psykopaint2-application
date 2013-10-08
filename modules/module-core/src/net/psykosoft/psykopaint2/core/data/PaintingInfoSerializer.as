package net.psykosoft.psykopaint2.core.data
{
	import flash.display.PNGEncoderOptions;
	import flash.utils.ByteArray;

	public class PaintingInfoSerializer
	{
		public function PaintingInfoSerializer()
		{
		}

		public function serialize(vo : PaintingInfoVO) : ByteArray
		{
			var bytes:ByteArray = new ByteArray();

			// Thumbnail bmd -> jpg.
			var thumbnailPNGBytes:ByteArray = vo.thumbnail.encode( vo.thumbnail.rect, new PNGEncoderOptions() );
			var thumbnailBytesLength:uint = thumbnailPNGBytes.length;

			bytes.writeUTF("IPP2");
			// Write exposed single value data.
			bytes.writeUTF( vo.fileVersion );
			bytes.writeUTF( vo.id );
			bytes.writeInt( vo.width );
			bytes.writeInt( vo.height );
			bytes.writeFloat( vo.lastSavedOnDateMs );
			bytes.writeUnsignedInt( thumbnailBytesLength );

			// Write images.
			bytes.writeBytes( thumbnailPNGBytes );
			var len:int = vo.width * vo.height * 4;
			bytes.writeBytes( vo.colorPreviewData, 0, len );
			bytes.writeBytes( vo.normalSpecularPreviewData, 0, len );

			bytes.position = 0;
			return bytes;
		}
	}
}
