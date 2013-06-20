package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.BitmapData;
	import flash.media.CameraRoll;

	public class IosImageSaveUtil
	{
		public static function saveImageToCameraRoll( bmd:BitmapData ):void {
			var cameraRoll:CameraRoll = new CameraRoll();
			cameraRoll.addBitmapData( bmd );
		}
	}
}
