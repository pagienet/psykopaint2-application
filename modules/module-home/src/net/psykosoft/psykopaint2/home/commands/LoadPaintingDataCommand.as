package net.psykosoft.psykopaint2.home.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

	import robotlegs.bender.framework.api.IContext;

	public class LoadPaintingDataCommand extends AsyncCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingDataModel:PaintingModel;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		private var _as3ReadUtil:BinaryIoUtil;

		override public function execute():void {
			super.execute();

			readAS3();
		}

		private function readAS3():void {
			if( !_as3ReadUtil ) {
				_as3ReadUtil = new BinaryIoUtil( CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP );
			}
			_as3ReadUtil.readBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, onAs3FileRead );
		}

		private function onAs3FileRead( bytes:ByteArray ):void {
			bytes.uncompress();
			onFileRead( bytes );
		}

		private function onFileRead( bytes:ByteArray ):void {

			// De-serialize.
			var deserializer:PaintingDataDeserializer = new PaintingDataDeserializer();
			var vo:PaintingDataVO = deserializer.deserialize( bytes );
			requestOpenPaintingDataVOSignal.dispatch(vo);
			if( _as3ReadUtil ) _as3ReadUtil.dispose();
			dispatchComplete( true );
		}
	}
}
