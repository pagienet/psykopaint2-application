package net.psykosoft.psykopaint2.base.utils.io
{

	import by.blooddy.crypto.image.PNG24Encoder;

	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class DesktopImageSaveUtil
	{
		public static function saveImageToDesktop( bmd:BitmapData ):void {

			// Encode to jpeg or png.
			var pngBytes:ByteArray = PNG24Encoder.encode( bmd );

			// Generate a dated image name.
			var nowDate:Date = new Date();
			var fileName:String = "psykopaint-2-snapshot - " + nowDate.toString() + ".png";
			trace( "DesktopImageSaveUtil - saving image: " + fileName );

			// Save image to desktop.
			var file:File = File.desktopDirectory.resolvePath( fileName );
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( pngBytes );
			fileStream.close();
		}
	}
}
