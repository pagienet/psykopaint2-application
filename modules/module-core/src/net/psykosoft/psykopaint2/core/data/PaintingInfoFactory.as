package net.psykosoft.psykopaint2.core.data
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;

	public class PaintingInfoFactory
	{
		// todo: parameterize?
		public static const SURFACE_PREVIEW_SHRINK_FACTOR : Number = 4; // powers of 2, integers > 1

		public function PaintingInfoFactory()
		{
		}

		public function createFromData(paintingData : PaintingDataVO, paintingId : String, userId : String, thumbnail : BitmapData) : PaintingInfoVO
		{
			var info : PaintingInfoVO = new PaintingInfoVO();
			var dateMs:Number = new Date().getTime();

			if( paintingId == PaintingInfoVO.DEFAULT_VO_ID ) {
				// Create id and focus model on it.
				paintingId = userId + "-" + dateMs;
				trace( this, "creating a new id: " + paintingId );
			}

			info.id = paintingId;
			info.lastSavedOnDateMs = dateMs;
			info.width = paintingData.width / SURFACE_PREVIEW_SHRINK_FACTOR;
			info.height = paintingData.height / SURFACE_PREVIEW_SHRINK_FACTOR;
			info.colorPreviewData = reduceSurface( paintingData.colorData, paintingData.width, paintingData.height, SURFACE_PREVIEW_SHRINK_FACTOR );
			info.normalSpecularPreviewData = reduceSurface( paintingData.normalSpecularData, paintingData.width, paintingData.height, SURFACE_PREVIEW_SHRINK_FACTOR );
			info.thumbnail = thumbnail

			return info;
		}

		// TODO: extremely slow, use native approach?
		private function reduceSurface( bytes:ByteArray, sourceWidth:uint, sourceHeight:uint, factor:uint ):ByteArray {
			// TODO: Li: remove and test code below
			{
				var clone : ByteArray = new ByteArray();
				clone.writeBytes(bytes, 0, 0);
				return clone;
			}

			var outputWidth : uint = sourceWidth / factor;
			var outputHeight : uint = sourceHeight / factor;
			var reducedBytes:ByteArray = new ByteArray();
			var startX : uint, startY : uint = 0;

			for( var y : uint = 0; y < outputHeight; ++y ) {
				startX = 0;
				var endY : uint = startY + factor;
				if (endY > sourceHeight) endY = sourceHeight;

				for( var x : uint = 0; x < outputWidth; ++x ) {
					var numSamples : uint = 0;
					var sampledB : uint = 0, sampledG : uint = 0, sampledR : uint = 0, sampledA : uint = 0;

					var endX : uint = startX + factor;
					if (endX > sourceWidth) endX = sourceWidth;

					for (var sampleY : uint = startY; sampleY < endY; ++sampleY) {
						bytes.position = (startX + sampleY*sourceWidth) << 2;
						for (var sampleX : uint = startX; sampleX < endX; ++sampleX) {
							var val : uint = bytes.readUnsignedInt();
							sampledB += (val & 0xff000000) >> 24;
							sampledG += (val & 0x00ff0000) >> 16;
							sampledR += (val & 0x0000ff00) >> 8;
							sampledA += val & 0x000000ff;
							++numSamples;
						}
					}

					var invSamples : Number = 1/numSamples;
					sampledB = uint(sampledB * invSamples) & 0xff;
					sampledG = uint(sampledG * invSamples) & 0xff;
					sampledR = uint(sampledR * invSamples) & 0xff;
					sampledA = uint(sampledA * invSamples) & 0xff;

					// Write average into destination.
					reducedBytes.writeUnsignedInt( (sampledB << 24) | (sampledG << 16) | (sampledR << 8) | sampledA );

					startX += factor;
				}
				startY += factor;
			}
			return reducedBytes;
		}
	}
}
