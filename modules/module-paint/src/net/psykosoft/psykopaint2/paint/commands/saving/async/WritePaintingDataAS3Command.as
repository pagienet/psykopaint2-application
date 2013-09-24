package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;

	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavingProcessModel;

	public class WritePaintingDataAS3Command extends AsyncCommand
	{
		[Inject]
		public var saveVO:SavingProcessModel;

		override public function execute():void {

		    ConsoleView.instance.log( this, "execute()" );

			var preFileName:String = ( CoreSettings.RUNNING_ON_iPAD ? "" : CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" ) + saveVO.paintingId;

			var dataWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) saveVO.dataBytes.compress();

			// Write data.
			dataWriteUtil = new BinaryIoUtil( storageType );
			dataWriteUtil.writeBytesAsync( preFileName + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, saveVO.dataBytes, onWriteComplete );
		}

		private function onWriteComplete():void {
			ConsoleView.instance.log( this, "onWriteComplete()" );
			dispatchComplete( true );
		}
	}
}
