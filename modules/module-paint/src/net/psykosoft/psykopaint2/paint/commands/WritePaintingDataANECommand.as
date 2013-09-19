package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	import robotlegs.bender.bundles.mvcs.Command;

	public class WritePaintingDataANECommand extends Command
	{
		[Inject]
		public var saveVO:SavePaintingVO;

		[Inject]
		public var ioAne:IOAneManager;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var stage:Stage;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

			requestUpdateMessagePopUpSignal.dispatch( "Saving: Writing...", "" );
			stage.addEventListener( Event.ENTER_FRAME, onOneFrame );
		}

		private function onOneFrame( event:Event ):void {
			stage.removeEventListener( Event.ENTER_FRAME, onOneFrame );
			write();
		}

		private function write():void {

			var time:uint = getTimer();

			// Write info bytes.
			var infoFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION;
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.writeWithCompression( saveVO.infoBytes, infoFileName );
			else ioAne.extension.write( saveVO.infoBytes, infoFileName );

			// Write data bytes.
			var dataFileName:String = saveVO.paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.writeWithCompression( saveVO.dataBytes, dataFileName );
			else ioAne.extension.write( saveVO.dataBytes, dataFileName );

			ConsoleView.instance.log( this, "done - " + String( getTimer() - time ) );
		}
	}
}
