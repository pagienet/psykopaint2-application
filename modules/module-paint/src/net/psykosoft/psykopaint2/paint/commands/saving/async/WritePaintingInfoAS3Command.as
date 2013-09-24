package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;

	import robotlegs.bender.bundles.mvcs.Command;

	public class WritePaintingInfoAS3Command extends Command
	{
		[Inject]
		public var saveVO:SavingProcessModel;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

			var preFileName:String = ( CoreSettings.RUNNING_ON_iPAD ? "" : CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" ) + saveVO.paintingId;

			var infoWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) saveVO.infoBytes.compress();

			// Write info.
			infoWriteUtil = new BinaryIoUtil( storageType );
			infoWriteUtil.writeBytesSync( preFileName + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, saveVO.infoBytes );
		}
	}
}
