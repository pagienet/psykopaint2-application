package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class BinarySaveUtil
	{
		public static function saveToDesktop( bytes:ByteArray, fileName:String ):void {
			var file:File = File.desktopDirectory.resolvePath( fileName );
			trace( "BinarySaveUtil - saving on desktop: " + file.nativePath );
			// TODO: use file.save() instead?
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( bytes );
			fileStream.close();
		}

		public static function saveToIos( bytes:ByteArray, fileName:String ):void {
			var file:File = File.applicationStorageDirectory.resolvePath( fileName );
			trace( "BinarySaveUtil - saving on ios: " + file.nativePath );
			// TODO: use file.save() instead?
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( bytes );
			fileStream.close();
		}
	}
}
