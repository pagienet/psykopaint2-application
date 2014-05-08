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

			if (paintingData.sourceImageData) {
				var sourceBmd : BitmapData = BitmapDataUtils.getBitmapDataFromBytes(paintingData.sourceImageData, canvas.width, canvas.height, false);
				canvas.setSourceBitmapData(sourceBmd);
				sourceBmd.dispose();
			}
			else
			// doing this to force creation of PyramidMap
			// TODO: Simply do not do this by allowing pyramid map not to exist
				canvas.setSourceBitmapData(null);

			canvas.colorTexture.uploadFromByteArray(paintingData.colorData, 0);

			if (paintingData.normalSpecularData)
				canvas.normalSpecularMap.uploadFromByteArray(paintingData.normalSpecularData, 0);
			else
				// new painting:
				canvas.normalSpecularMap.uploadFromBitmapData(paintingData.normalSpecularOriginal);

			canvas.setNormalSpecularOriginal(paintingData.normalSpecularOriginal);
			canvas.setColorBackgroundOriginal(paintingData.colorBackgroundOriginal);

			paintingData.normalSpecularOriginal = null;
			paintingData.colorBackgroundOriginal = null;
		}
	}
}
