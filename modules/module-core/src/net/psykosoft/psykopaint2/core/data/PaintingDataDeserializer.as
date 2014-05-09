package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;

	public class PaintingDataDeserializer
	{
		public function PaintingDataDeserializer()
		{
		}

		public function deserialize(bytes : TrackedByteArray) : PaintingDataVO
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
			trace( this, "isPhotoPainting",isPhotoPainting );
			var hasColorBackgroundOriginal : Boolean = bytes.readBoolean();
			trace( this, "hasColorBackgroundOriginal",hasColorBackgroundOriginal );
			
			vo.colorPalettes = PaintingFileUtils.readColorPalettes(bytes);
			
			// Read painting surfaces.
			vo.colorData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			var temp : TrackedByteArray = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			vo.normalSpecularOriginal = new BitmapData(vo.width, vo.height, false);
			vo.normalSpecularOriginal.setPixels(vo.normalSpecularOriginal.rect, temp);
			temp.clear();

			if (isPhotoPainting)
			{
				vo.sourceImageData = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			}
			if (hasColorBackgroundOriginal){
				vo.colorBackgroundOriginal = PaintingFileUtils.decodeImage(bytes, vo.width, vo.height);
			}
			
			//Hopefully this is okay to do here:
			bytes.clear();
			
			return vo;
		}

	}
}
