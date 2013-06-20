package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class DesktopBinarySaveUtil
	{
		public static function saveToDesktop( bytes:ByteArray, fileName:String ):void {
			// Save data to desktop.
			var file:File = File.desktopDirectory.resolvePath( fileName );
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( bytes );
			fileStream.close();
		}
	}
}
