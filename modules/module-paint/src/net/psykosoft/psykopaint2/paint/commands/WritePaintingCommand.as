package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	public class WritePaintingCommand extends AsyncCommand
	{
		[Inject]
		public var saveVO:SavePaintingVO;

		private const ASYNC_MODE:Boolean = false;

		override public function execute():void {
			trace( this + ", execute()" );
			writeInfoBytes();
		}

		private function writeInfoBytes():void {

			// TODO: using sync saving for now, async makes writing fail on ipad slow packaging, see notes here: https://github.com/psykosoft/psykopaint2-application/issues/47

			var infoWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			// Write info.
			infoWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + saveVO.paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, saveVO.infoBytes, writeDataBytes );
			}
			else {
				infoWriteUtil.writeBytesSync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + saveVO.paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, saveVO.infoBytes );
				writeDataBytes();
			}
		}

		private function writeDataBytes():void {

			var dataWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			// Write data.
			dataWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + saveVO.paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, saveVO.dataBytes, onWriteComplete );
			}
			else {
				dataWriteUtil.writeBytesSync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + saveVO.paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, saveVO.dataBytes );
				onWriteComplete();
			}
		}

		private function onWriteComplete():void {
			dispatchComplete( true );
		}
	}
}
