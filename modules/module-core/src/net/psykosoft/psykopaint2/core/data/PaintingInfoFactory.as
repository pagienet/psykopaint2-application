package net.psykosoft.psykopaint2.core.data
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

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


			var paintingDate:Number = Number( paintingId.split( "-" )[ 1 ] );
			trace( this, "paintingDate: " + paintingDate );
			if( isNaN( paintingDate ) ) {
				// Create id and focus model on it.
				paintingId = userId + "-" + dateMs;
				trace( this, "creating new id: " + paintingId );
			}

			info.id = paintingId;
			info.lastSavedOnDateMs = dateMs;
			info.width = paintingData.width / SURFACE_PREVIEW_SHRINK_FACTOR;
			info.height = paintingData.height / SURFACE_PREVIEW_SHRINK_FACTOR;
			info.colorPreviewData= reduceSurface( paintingData.colorData, paintingData.width, paintingData.height, SURFACE_PREVIEW_SHRINK_FACTOR );
			info.normalSpecularPreviewData = reduceSurface( paintingData.normalSpecularData, paintingData.width, paintingData.height, SURFACE_PREVIEW_SHRINK_FACTOR );
			info.thumbnail = thumbnail;

			return info;
		}

		// TODO: extremely slow, use native approach?
		private function reduceSurface( bytes:ByteArray, sourceWidth:uint, sourceHeight:uint, factor:uint ):RefCountedByteArray {
			var outputWidth : uint = sourceWidth / factor;
			var outputHeight : uint = sourceHeight / factor;
			var reducedBytes:RefCountedByteArray = new RefCountedByteArray();
			var sampleX : uint, sampleY : uint = 0;

			for( var y : uint = 0; y < outputHeight; ++y ) {
				sampleX = 0;
				for( var x : uint = 0; x < outputWidth; ++x ) {
					bytes.position = (sampleX + sampleY*sourceWidth) << 2;
					reducedBytes.writeUnsignedInt( bytes.readUnsignedInt() );
					sampleX += factor;
				}
				sampleY += factor;
			}
			return reducedBytes;
		}
	}
}
