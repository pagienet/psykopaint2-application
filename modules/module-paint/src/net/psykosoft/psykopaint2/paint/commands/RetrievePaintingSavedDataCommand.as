package net.psykosoft.psykopaint2.paint.commands
{

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopFolderReadUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;

	public class RetrievePaintingSavedDataCommand extends TracingCommand
	{
		public function RetrievePaintingSavedDataCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Read files in app data folder or bundle.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else {
				var files:Array = DesktopFolderReadUtil.readFilesInFolder( PaintSettings.saveDataFolderName );
				trace( this, "found files: >>>" + files + "<<<" );
			}
		}
	}
}
