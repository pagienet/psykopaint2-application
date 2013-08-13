package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;

	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class CanvasImporter
	{
		public function CanvasImporter()
		{
		}

		public function importPainting(canvas : CanvasModel, paintingData : PaintingDataVO) : void
		{
			if (canvas.width != paintingData.width || canvas.height != paintingData.height)
				throw new Error("Different painting sizes currently not supported!");

			var sourceBmd : BitmapData = BitmapDataUtils.getBitmapDataFromBytes(paintingData.sourceBitmapData, canvas.width, canvas.height, false);
			canvas.setSourceBitmapData(sourceBmd);
			sourceBmd.dispose();

			var oldLength : int = paintingData.colorData.length;
			var newLength : int = canvas.textureWidth * canvas.textureHeight * 4;

			paintingData.colorData.length = newLength;
			canvas.colorTexture.uploadFromByteArray(paintingData.colorData, 0, 0);
			paintingData.colorData.length = oldLength;

			paintingData.normalSpecularData.length = newLength;
			canvas.normalSpecularMap.uploadFromByteArray(paintingData.normalSpecularData, 0, 0);
			paintingData.normalSpecularData.length = oldLength;

			canvas.setNormalSpecularOriginal(paintingData.normalSpecularOriginal);
			canvas.setColorBackgroundOriginal(paintingData.colorBackgroundOriginal);
		}
	}
}
