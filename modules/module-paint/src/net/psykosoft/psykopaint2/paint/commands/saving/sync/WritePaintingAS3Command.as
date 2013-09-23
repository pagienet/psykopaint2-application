package net.psykosoft.psykopaint2.paint.commands.saving.sync
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.display.Stage;
	import flash.events.Event;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavingProcessModel;

	public class WritePaintingAS3Command extends AsyncCommand
	{
		[Inject]
		public var saveVO:SavingProcessModel;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var stage:Stage;

		private var _time:uint;
		private var _preFileName:String;

		private const ASYNC_MODE:Boolean = false;

		// TODO: remove ios impl. as this is now only being used for desktop

		override public function execute():void {
			ConsoleView.instance.log( this, "execute()" );
			_time = getTimer();

			requestUpdateMessagePopUpSignal.dispatch( "Saving: Writing...", "" );
			stage.addEventListener( Event.ENTER_FRAME, onOneFrame );
		}

		private function onOneFrame( event:Event ):void {
			stage.removeEventListener( Event.ENTER_FRAME, onOneFrame );
			write();
		}

		private function write():void {
			_preFileName = ( CoreSettings.RUNNING_ON_iPAD ? "" : CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" ) + saveVO.paintingId;
			writeInfoBytes();
		}

		private function writeInfoBytes():void {

			trace( this, "vo: " + saveVO );

			// TODO: using sync saving for now, async makes writing fail on ipad slow packaging, see notes here: https://github.com/psykosoft/psykopaint2-application/issues/47

			var infoWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) saveVO.infoBytes.compress();

			// Write info.
			infoWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				infoWriteUtil.writeBytesAsync( _preFileName + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, saveVO.infoBytes, writeDataBytes );
			}
			else {
				infoWriteUtil.writeBytesSync( _preFileName + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, saveVO.infoBytes );
				writeDataBytes();
			}
		}

		private function writeDataBytes():void {

			var dataWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) saveVO.dataBytes.compress();

			// Write data.
			dataWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				dataWriteUtil.writeBytesAsync( _preFileName + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, saveVO.dataBytes, onWriteComplete );
			}
			else {
				dataWriteUtil.writeBytesSync( _preFileName + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, saveVO.dataBytes );
				onWriteComplete();
			}
		}

		private function onWriteComplete():void {
			dispatchComplete( true );
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
