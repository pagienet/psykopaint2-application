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
			PaintingFileUtils.uncompressData(bytes);

			// Read dimensions.
			vo.width = bytes.readInt();
			vo.height = bytes.readInt();

			// Read painting surfaces.
			vo.colorData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.sourceBitmapData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);

			return vo;
		}

	}
}