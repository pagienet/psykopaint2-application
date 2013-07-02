package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.filesystem.File;

	public class FolderReadUtil
	{
		public static function readFilesInDesktopFolder( folderName:String ):Array {
			var dir:File = File.desktopDirectory.resolvePath( folderName );
			var list:Array = [];
			try {
				list = dir.getDirectoryListing();
			}
			catch( error:Error ) {
				trace( "***WARNING*** FolderReadUtil - readFilesInDesktopFolder() - could not find folder: " + folderName );
			}
			return list;
		}

		public static function readFilesInIosFolder( folderName:String ):Array {
			var dir:File = File.applicationStorageDirectory.resolvePath( folderName );
			var list:Array = [];
			try {
				list = dir.getDirectoryListing();
			}
			catch( error:Error ) {
				trace( "***WARNING*** FolderReadUtil - readFilesInIosFolder() - could not find folder: " + folderName );
			}
			return list;
		}
	}
}
