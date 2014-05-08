package net.psykosoft.psykopaint2.core.models
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class PaintingGalleryVO
	{
		public var normalSpecularData :  BitmapData;
		public var colorData : BitmapData;
		public var sourceThumbnail :  BitmapData;

		public function dispose() : void
		{
			// might be disposed mid-load, so null-guard the required fields too
			if (normalSpecularData) normalSpecularData.dispose();
			if (colorData) colorData.dispose();
			if (sourceThumbnail) sourceThumbnail.dispose();

			normalSpecularData = null;
			colorData = null;
			sourceThumbnail = null;
		}
	}
}
