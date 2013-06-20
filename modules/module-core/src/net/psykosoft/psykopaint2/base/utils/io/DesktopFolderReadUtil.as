package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.filesystem.File;

	public class DesktopFolderReadUtil
	{
		// Assumes folder is in desktop.
		public static function readFilesInFolder( folderName:String ):Array {
			var dir:File = File.desktopDirectory.resolvePath( folderName );
			var list:Array = [];
			try {
				list = dir.getDirectoryListing();
			}
			catch( error:Error ) {
				trace( "***WARNING*** DesktopFolderReadUtil - readFilesInFolder() - could not find folder: " + folderName );
			}
			return list;
		}
	}
}
