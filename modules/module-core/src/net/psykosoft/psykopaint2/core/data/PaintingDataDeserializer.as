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

			// Read dimensions.
			vo.width = bytes.readInt();
			vo.height = bytes.readInt();
			trace( this, "width: " + vo.width + ", height: " + vo.height );

			// Read painting surfaces.
			vo.colorData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.sourceImageData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularOriginal = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			if (bytes.bytesAvailable > 0)
				vo.colorBackgroundOriginal = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			return vo;
		}

	}
}
