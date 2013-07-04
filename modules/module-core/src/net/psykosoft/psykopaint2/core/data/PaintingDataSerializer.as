package net.psykosoft.psykopaint2.core.data
{
	import flash.utils.ByteArray;

	public class PaintingDataSerializer
	{
		public function PaintingDataSerializer()
		{
		}

		public function serialize(vo : PaintingDataVO) : ByteArray
		{
			var bytes : ByteArray = new ByteArray();

			// Write dimensions.
			bytes.writeInt(vo.width);
			bytes.writeInt(vo.height);

			// Write surfaces.
			var len : uint = vo.width * vo.height * 4;
			bytes.writeBytes(vo.surfaces[ 0 ], 0, len);
			bytes.writeBytes(vo.surfaces[ 1 ], 0, len);
			bytes.writeBytes(vo.surfaces[ 2 ], 0, len);

			PaintingFileUtils.compressData(bytes);

			bytes.position = 0;
			return bytes;
		}
	}
}
