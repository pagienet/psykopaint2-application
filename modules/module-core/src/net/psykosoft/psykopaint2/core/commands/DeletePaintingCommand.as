package  net.psykosoft.psykopaint2.core.commands {

	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	public class DeletePaintingCommand extends TracingCommand {

		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		public function DeletePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			//identify file names
			var dataFileName:String = CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;
			var infoFileName:String = CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION;
			
			
			//delete files
			var dataFile:File;
			var infoFile:File;
			if( CoreSettings.RUNNING_ON_iPAD ) {
				//File.applicationStorageDirectory doesn't work. 
				dataFile = File.documentsDirectory.resolvePath( paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION );
				infoFile = File.documentsDirectory.resolvePath( paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION );
			}
			else {
				dataFile = File.desktopDirectory.resolvePath( dataFileName );
				infoFile = File.desktopDirectory.resolvePath( infoFileName );
			}
			if ( dataFile.exists ) dataFile.deleteFile();
			else trace("ERROR: DeletePaintingCommand - file does not exist: "+dataFileName);
			if ( infoFile.exists ) infoFile.deleteFile();
			else trace("ERROR: DeletePaintingCommand - file does not exist: "+infoFileName);
		}
	}
}
