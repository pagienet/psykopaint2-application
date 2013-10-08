package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;

	public class PaintingDataDeserializer
	{
		public function PaintingDataDeserializer()
		{
		}

		public function deserialize(bytes : ByteArray) : PaintingDataVO
		{
			var vo : PaintingDataVO = new PaintingDataVO();

			if (bytes.readUTF() != "DPP2")
				throw "Incorrect file type";

			// TODO: Make backwards compatible
			if (bytes.readUTF() != PaintingFileUtils.PAINTING_FILE_VERSION)
				throw "Incorrect file version";

			// Read dimensions.
			vo.width = bytes.readInt();
			vo.height = bytes.readInt();

			trace( this, "width: " + vo.width + ", height: " + vo.height );

			var isPhotoPainting : Boolean = bytes.readBoolean();

			// Read painting surfaces.
			vo.colorData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularOriginal = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			if (isPhotoPainting)
				vo.sourceImageData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			if (bytes.bytesAvailable > 0)
				vo.colorBackgroundOriginal = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			return vo;
		}

	}
}
