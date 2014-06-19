package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;

	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorAndSourceToBitmapDataUtil;

	public class CanvasIPPSerializer
	{
		public static const SURFACE_PREVIEW_SHRINK_FACTOR : Number = 4;

		private static var _copyColorAndSourceToBitmapData:CopyColorAndSourceToBitmapDataUtil;

		private var _output : ByteArray;

		// powers of 2, integers > 1

		public function CanvasIPPSerializer()
		{
			_copyColorAndSourceToBitmapData ||= new CopyColorAndSourceToBitmapDataUtil();
		}

		public function serialize(paintingID : String, lastSavedOnDateMs : Number, canvas : CanvasModel, canvasRenderer : CanvasRenderer, paintSettings : UserPaintSettingsModel, dpp : ByteArray) : ByteArray
		{
			_output = new ByteArray();
			dpp.position = 0;
			dpp.readUTF();	// skip DPP2
			dpp.readUTF();	// skip version
			var width : int = dpp.readInt();
			var height : int = dpp.readInt();

			writeHeader(paintingID, lastSavedOnDateMs, width, height);
			dpp.readBoolean();	// skip isPhotoPainting

			writeThumbnail(canvasRenderer);

			var position : int = dpp.position;
			var len : int = width * height * 4;
			mergeColor(canvas);
			reduceSurface(dpp, width, height, position + len);	// normal specular data

			dpp.position = 0;
			_output.position = 0;

			return cleanUpAndReturn();
		}

		private function mergeColor(canvas:CanvasModel):void
		{
			var offset : int = _output.position;
			var largeBitmapData : BitmapData = _copyColorAndSourceToBitmapData.execute(canvas);
			var smallBitmapData : BitmapData = new BitmapData(canvas.width / SURFACE_PREVIEW_SHRINK_FACTOR, canvas.height / SURFACE_PREVIEW_SHRINK_FACTOR, false);
			smallBitmapData.draw(largeBitmapData, new Matrix(1.0/SURFACE_PREVIEW_SHRINK_FACTOR, 0, 0, 1.0/SURFACE_PREVIEW_SHRINK_FACTOR));
			largeBitmapData.dispose();
			smallBitmapData.copyPixelsToByteArray(smallBitmapData.rect, _output);
			ImageDataUtils.ARGBtoBGRA(_output, smallBitmapData.width * smallBitmapData.height * 4, offset);
			smallBitmapData.dispose();

			_output.position = _output.length;
		}

		private function writeHeader(paintingID : String, lastSavedOnDateMs : Number, width : int, height : int) : void
		{
			_output.writeUTF("IPP2");
			// Write exposed single value data.
			_output.writeUTF(PaintingFileUtils.PAINTING_FILE_VERSION);
			_output.writeUTF(paintingID);
			_output.writeInt(width / SURFACE_PREVIEW_SHRINK_FACTOR);
			_output.writeInt(height / SURFACE_PREVIEW_SHRINK_FACTOR);
			_output.writeFloat(lastSavedOnDateMs);
		}

		private function writeThumbnail(canvasRenderer : CanvasRenderer) : void
		{
			// store temporary length of 0 so we can generate the png as we go
			_output.writeUnsignedInt(0);

			var thumbnail : BitmapData = generateThumbnail(canvasRenderer);
			var thumbnailStartPos : uint = _output.position;
			thumbnail.encode(thumbnail.rect, new PNGEncoderOptions(), _output);
			thumbnail.dispose();

			var thumbnailBytesLength : uint = _output.position - thumbnailStartPos;
			_output.position = thumbnailStartPos - 4;
			_output.writeUnsignedInt(thumbnailBytesLength);
			_output.position += thumbnailBytesLength;
		}

		private function generateThumbnail(canvasRenderer : CanvasRenderer) : BitmapData
		{
			// TODO: generate thumbnail by accepting scale in renderToBitmapData
			var thumbnail : BitmapData = canvasRenderer.renderToBitmapData();
			var scaledThumbnail : BitmapData = BitmapDataUtils.scaleBitmapData(thumbnail, 0.25); // TODO: apply different scales depending on source and target resolutions
			thumbnail.dispose();
			return scaledThumbnail;
		}

		private function reduceSurface(sourceData : ByteArray, sourceWidth : uint, sourceHeight : uint, offset : uint) : void
		{
			var outputWidth : uint = sourceWidth / SURFACE_PREVIEW_SHRINK_FACTOR;
			var outputHeight : uint = sourceHeight / SURFACE_PREVIEW_SHRINK_FACTOR;
			var sampleX : uint, sampleY : uint = 0;

			for (var y : uint = 0; y < outputHeight; ++y) {
				sampleX = 0;
				for (var x : uint = 0; x < outputWidth; ++x) {
					sourceData.position = offset + ((sampleX + sampleY * sourceWidth) << 2);
					var value : uint = sourceData.readUnsignedInt();
					_output.writeUnsignedInt(value);
					sampleX += SURFACE_PREVIEW_SHRINK_FACTOR;
				}
				sampleY += SURFACE_PREVIEW_SHRINK_FACTOR;
			}
		}

		private function cleanUpAndReturn() : ByteArray
		{
			var output : ByteArray = _output;
			_output = null;
			return output;
		}
	}
}
