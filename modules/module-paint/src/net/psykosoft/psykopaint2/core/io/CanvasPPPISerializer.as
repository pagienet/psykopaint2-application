package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;
	import net.psykosoft.psykopaint2.core.data.PPPIFileData;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorAndSourceToBitmapDataUtil;

	public class CanvasPPPISerializer
	{
		public static const SURFACE_PREVIEW_SHRINK_FACTOR : Number = 4;

		private static var _copyColorAndSourceToBitmapData:CopyColorAndSourceToBitmapDataUtil;


		// powers of 2, integers > 1

		public function CanvasPPPISerializer()
		{
			_copyColorAndSourceToBitmapData ||= new CopyColorAndSourceToBitmapDataUtil();
		}

		public function serialize(paintingID : String, lastSavedOnDateMs : Number, canvas : CanvasModel, canvasRenderer : CanvasRenderer, paintSettings : UserPaintSettingsModel,ppp:ByteArray) : ByteArray
		{
			var newPPPIFileData:PPPIFileData = new PPPIFileData();
			
			//MATHIEU:
			//NOW USING PPP:
			
			var width : int = canvas.width;
			var height : int = canvas.height;
			
			
			// Write exposed single value data.
			newPPPIFileData.version = PaintingFileUtils.PAINTING_FILE_VERSION;
			newPPPIFileData.id=paintingID;
			newPPPIFileData.width = width / SURFACE_PREVIEW_SHRINK_FACTOR;
			newPPPIFileData.height = height / SURFACE_PREVIEW_SHRINK_FACTOR;
			newPPPIFileData.dateTimestamp = lastSavedOnDateMs;
			
			
			//WRITE THUMBNAIL BMD
			
			//thumbnail.encode(thumbnail.rect, new PNGEncoderOptions(true), _output);
			//thumbnail.dispose();
			
			//var bytes:ByteArray = new ByteArray();
			//var thumbnail : BitmapData = generateThumbnail(canvasRenderer);
			//thumbnail.encode(thumbnail.rect, new PNGEncoderOptions(), bytes);
			//newPPPIFileData.colorPreviewData = bytes;
			
			var bytes:ByteArray = new ByteArray();
			var offset : int = 0;
			var largeBitmapData : BitmapData = _copyColorAndSourceToBitmapData.execute(canvas);
			var smallBitmapData : BitmapData = new BitmapData(canvas.width / SURFACE_PREVIEW_SHRINK_FACTOR, canvas.height / SURFACE_PREVIEW_SHRINK_FACTOR, false);
			smallBitmapData.draw(largeBitmapData, new Matrix(1.0/SURFACE_PREVIEW_SHRINK_FACTOR, 0, 0, 1.0/SURFACE_PREVIEW_SHRINK_FACTOR));
			largeBitmapData.dispose();
			smallBitmapData.copyPixelsToByteArray(smallBitmapData.rect, bytes);
			newPPPIFileData.thumbnailBmd = new ByteArray();
			newPPPIFileData.thumbnailBmd.writeBytes(bytes);
			ImageDataUtils.ARGBtoBGRA(bytes, smallBitmapData.width * smallBitmapData.height * 4, offset);
			
			newPPPIFileData.colorPreviewData = bytes;
			
			
			//THIS I NEED TO FIX. BREAKS SOMETIMES BECAUSE OF CANVAS RENDERER
			// I JUST NEED TO SAVE REFERENCE OF THE ORIGINAL SURFACE ANYWAY
			var surfaceBytes:ByteArray = new ByteArray();
			var normalSpecularBmd: BitmapData = canvas.getNormalSpecularOriginal();
			//MATHIEU HACK TO HAVE FLAT SURFACE, SURFACE ALWAYS LOOK WEIRD IN PREVIEW
			normalSpecularBmd = new BitmapData(width,height,false,0x555555);
			normalSpecularBmd.copyPixelsToByteArray(normalSpecularBmd.rect, surfaceBytes);
			newPPPIFileData.normalSpecularPreviewData = reduceSurface(surfaceBytes, width, height, 0);	// normal specular data
			
			
			var filebytes : ByteArray = new ByteArray();
			filebytes.objectEncoding = ObjectEncoding.AMF3;
			filebytes.writeObject(newPPPIFileData);
			
			return filebytes;
		}
		
		
		
		
		
		private function mergeColor(canvas:CanvasModel):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			var offset : int = 0;
			var largeBitmapData : BitmapData = _copyColorAndSourceToBitmapData.execute(canvas);
			var smallBitmapData : BitmapData = new BitmapData(canvas.width / SURFACE_PREVIEW_SHRINK_FACTOR, canvas.height / SURFACE_PREVIEW_SHRINK_FACTOR, false);
			smallBitmapData.draw(largeBitmapData, new Matrix(1.0/SURFACE_PREVIEW_SHRINK_FACTOR, 0, 0, 1.0/SURFACE_PREVIEW_SHRINK_FACTOR));
			largeBitmapData.dispose();
			smallBitmapData.copyPixelsToByteArray(smallBitmapData.rect, bytes);
			ImageDataUtils.ARGBtoBGRA(bytes, smallBitmapData.width * smallBitmapData.height * 4, offset);
			smallBitmapData.dispose();

			return bytes
		}
		
		
	
		/*
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
		}*/

		private function generateThumbnail(canvasRenderer : CanvasRenderer) : BitmapData
		{
			// TODO: generate thumbnail by accepting scale in renderToBitmapData
			var thumbnail : BitmapData = canvasRenderer.renderToBitmapData();
			var scaledThumbnail : BitmapData = BitmapDataUtils.scaleBitmapData(thumbnail, 0.25); // TODO: apply different scales depending on source and target resolutions
			thumbnail.dispose();
			return scaledThumbnail;
		}
		
		private function reduceSurface(sourceData : ByteArray, sourceWidth : uint, sourceHeight : uint, offset : uint) : ByteArray
		{
			var returnBytes:ByteArray = new ByteArray();
			var outputWidth : uint = sourceWidth / SURFACE_PREVIEW_SHRINK_FACTOR;
			var outputHeight : uint = sourceHeight / SURFACE_PREVIEW_SHRINK_FACTOR;
			var sampleX : uint, sampleY : uint = 0;

			for (var y : uint = 0; y < outputHeight; ++y) {
				sampleX = 0;
				for (var x : uint = 0; x < outputWidth; ++x) {
					sourceData.position = offset + ((sampleX + sampleY * sourceWidth) << 2);
					var value : uint = sourceData.readUnsignedInt();
					returnBytes.writeUnsignedInt(value);
					sampleX += SURFACE_PREVIEW_SHRINK_FACTOR;
				}
				sampleY += SURFACE_PREVIEW_SHRINK_FACTOR;
			}
			return returnBytes;
		}

		
	}
}
