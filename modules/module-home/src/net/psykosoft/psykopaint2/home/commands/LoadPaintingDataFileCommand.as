package net.psykosoft.psykopaint2.home.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

	public class LoadPaintingDataFileCommand extends AsyncCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingModel;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		[Inject]
		public var ioAne:IOAneManager;

		private var _fileName:String;
		private var _as3ReadUtil:BinaryIoUtil;
		private var _time:uint;

		override public function execute():void {

			trace( this, "execute()" );
			_time = getTimer();

			var folder:String = CoreSettings.RUNNING_ON_iPAD ? "" : CoreSettings.PAINTING_DATA_FOLDER_NAME + "/";
			_fileName = folder + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;

			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) readANE();
			else readAS3();
		}

		private function readAS3():void {
			if( !_as3ReadUtil ) {
				_as3ReadUtil = new BinaryIoUtil( CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP );
			}
			_as3ReadUtil.readBytesAsync( _fileName, onAs3FileRead );
		}

		private function onAs3FileRead( bytes:ByteArray ):void {
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) bytes.uncompress();
			onFileRead( bytes );
		}

		private function readANE():void {
			trace( this, "reading with ane... " + _fileName );
			var bytes:ByteArray = new ByteArray();
	   		if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.readWithDeCompression( bytes, _fileName );
			else ioAne.extension.read( bytes, _fileName );
			onFileRead( bytes );
		}

		private function onFileRead( bytes:ByteArray ):void {

			trace( this, "file read: " + bytes.length );

			// De-serialize.
			var deserializer:PaintingDataDeserializer = new PaintingDataDeserializer();
			var vo:PaintingDataVO = deserializer.deserialize( bytes );
			requestOpenPaintingDataVOSignal.dispatch(vo);
			if( _as3ReadUtil ) _as3ReadUtil.dispose();
			dispatchComplete( true );
			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
		}
	}
}
