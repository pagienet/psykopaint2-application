package net.psykosoft.psykopaint2.paint.commands {
import flash.filesystem.File;

import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
import net.psykosoft.psykopaint2.core.config.CoreSettings;
import net.psykosoft.psykopaint2.core.models.PaintingModel;
import net.psykosoft.psykopaint2.core.models.StateType;
import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;

public class DeletePaintingCommand extends TracingCommand {

		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var requestZoomToggleSignal:RequestZoomToggleSignal;

		public function DeletePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			//identify file name
			var fileName:String = CoreSettings.PAINTING_DATA_FOLDER_NAME + "/painting-" + paintingId + CoreSettings.PAINTING_FILE_EXTENSION;

			//delete file name
			var file:File;
			if( CoreSettings.RUNNING_ON_iPAD ) {
				file = File.applicationStorageDirectory.resolvePath( fileName );
			}
			else {
				file = File.desktopDirectory.resolvePath( fileName );
			}
			file.deleteFile();

			//delete painting vo
			paintingModel.deleteVoWithId( paintingId );

			//change state to home
			requestStateChangeSignal.dispatch( StateType.HOME_ON_EASEL );

			//zoom out
			requestZoomToggleSignal.dispatch( false );

		}
	}
}
