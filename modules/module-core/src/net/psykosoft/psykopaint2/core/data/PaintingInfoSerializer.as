package net.psykosoft.psykopaint2.core.data
{
	import flash.display.JPEGEncoderOptions;
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
			bytes.writeBytes( vo.colorPreviewData, 0, len );
			bytes.writeBytes( vo.normalSpecularPreviewData, 0, len );

			PaintingFileUtils.compressData( bytes );

			bytes.position = 0;
			return bytes;
		}
	}
}