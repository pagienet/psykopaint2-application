package net.psykosoft.psykopaint2.paint.commands
{

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	import robotlegs.bender.bundles.mvcs.Command;

	public class WritePaintingDataANECommand extends Command
	{
		[Inject]
		public var saveVO:SavePaintingVO;

		[Inject]
		public var ioAne:IOAneManager;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );
			var time:uint = getTimer();

			// Write info bytes.
			var infoFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION;
			ioAne.extension.writeWithCompression( saveVO.infoBytes, infoFileName );

			// Write data bytes.
			var dataFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;
			ioAne.extension.writeWithCompression( saveVO.dataBytes, dataFileName );

			ConsoleView.instance.log( this, "done - " + String( getTimer() - time ) );
		}
	}
}
