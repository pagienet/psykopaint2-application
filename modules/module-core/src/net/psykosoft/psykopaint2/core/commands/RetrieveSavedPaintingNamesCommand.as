package net.psykosoft.psykopaint2.core.commands
{

	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.utils.io.FolderReadUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.data.RetrievePaintingsDataProcessModel;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RetrieveSavedPaintingNamesCommand extends Command
	{
		[Inject]
		public var vo:RetrievePaintingsDataProcessModel;

		override public function execute():void {

			// Read files in app data folder or bundle.
			var files:Array;
			if( CoreSettings.RUNNING_ON_iPAD ) files = FolderReadUtil.readFilesInIosFolder( "" );
			else files = FolderReadUtil.readFilesInDesktopFolder( CoreSettings.PAINTING_DATA_FOLDER_NAME );
			var len:uint = files.length;
			trace( this, "found files in paint data: " + len );

			// Sweep files and focus on the ones that have the .psy extension, which represents paintings.
			vo.paintingFileNames = new Vector.<String>();
			for( var i:uint; i < len; i++ ) {
				var file:File = files[ i ];
				trace( "  file: " + file.name );
				if( file.name.indexOf( PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION ) != -1 ) {
					vo.paintingFileNames.push( file.name );
				}
			}
			vo.numPaintingFiles = vo.paintingFileNames.length;
		}
	}
}
