package net.psykosoft.psykopaint2.core.data
{
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;

	public class PaintingDataSerializer
	{
		public function PaintingDataSerializer()
		{
		}

		public function serialize(vo : PaintingDataVO) : ByteArray
		{
			var bytes : ByteArray = new ByteArray();

			bytes.writeUTF("DPP2");
			bytes.writeUTF(PaintingFileUtils.PAINTING_FILE_VERSION);

			// Write dimensions.
			bytes.writeInt(vo.width);
			bytes.writeInt(vo.height);

			// write isPhotoPainting flag
			bytes.writeBoolean(vo.sourceImageData != null);

			// Write surfaces.
			append(vo, vo.colorData, bytes);
			append(vo, vo.normalSpecularData, bytes);
			append(vo, vo.normalSpecularOriginal, bytes);
			if (vo.sourceImageData != null)
				append(vo, vo.sourceImageData, bytes);
			if (vo.colorBackgroundOriginal)
				append(vo, vo.colorBackgroundOriginal, bytes);

			bytes.position = 0;
			return bytes;
		}

		private function append(vo : PaintingDataVO, source : ByteArray, target : ByteArray) : void
		{
			var len : int = vo.width * vo.height * 4;
			var oldLen : int = source.length;

			source.position = 0;

			if (oldLen != len)
				source.length = len;

			target.writeBytes(source, 0, len);

			if (oldLen != len)
				source.length = oldLen;
		}
	}
}
