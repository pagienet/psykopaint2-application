package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;

	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;

	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavingProcessModel;

	public class WritePaintingDataANECommand extends AsyncCommand
	{
		[Inject]
		public var saveVO:SavingProcessModel;

		[Inject]
		public var ioAne:IOAneManager;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

			// Write data bytes.
			var dataFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;
			ConsoleView.instance.log( this, "file name: " + dataFileName );
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.writeWithCompressionAsync( saveVO.dataBytes, dataFileName, onWriteComplete );
			else ioAne.extension.writeAsync( saveVO.dataBytes, dataFileName, onWriteComplete );
		}

		private function onWriteComplete():void {
			ConsoleView.instance.log( this, "onWriteComplete()" );
			dispatchComplete( true );
		}
	}
}
