package net.psykosoft.psykopaint2.paint.commands {

	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
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
				dataFile = File.applicationStorageDirectory.resolvePath( dataFileName );
				infoFile = File.applicationStorageDirectory.resolvePath( infoFileName );
			}
			else {
				dataFile = File.desktopDirectory.resolvePath( dataFileName );
				infoFile = File.desktopDirectory.resolvePath( infoFileName );
			}
			dataFile.deleteFile();
			infoFile.deleteFile();

			//change state to home
			requestStateChangeSignal.dispatch( NavigationStateType.TRANSITION_TO_HOME_MODE );
		}
	}
}
