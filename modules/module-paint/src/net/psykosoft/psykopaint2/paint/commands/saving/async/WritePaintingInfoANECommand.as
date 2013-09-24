package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;

	import robotlegs.bender.bundles.mvcs.Command;

	public class WritePaintingInfoANECommand extends Command
	{
		[Inject]
		public var saveVO:SavingProcessModel;

		[Inject]
		public var ioAne:IOAneManager;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

			// Write info bytes.
			var infoFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION;
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.writeWithCompression( saveVO.infoBytes, infoFileName );
			else ioAne.extension.write( saveVO.infoBytes, infoFileName );
		}
	}
}
