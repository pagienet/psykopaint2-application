package net.psykosoft.psykopaint2.home.commands
{

	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;
	
	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.core.views.popups.base.Quotes;
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

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var notifyPopUpShownSignal:NotifyPopUpShownSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		private var _fileName:String;
		private var _as3ReadUtil:BinaryIoUtil;
		private var _time:uint;

		override public function execute():void {
			trace( this, "execute()" );
			showPopUp();
		}

		private function showPopUp():void {
			requestShowPopUpSignal.dispatch( PopUpType.MESSAGE );
			var randomQuote:String = Quotes.QUOTES[ Math.floor( Quotes.QUOTES.length * Math.random() ) ];
			requestUpdateMessagePopUpSignal.dispatch( "Loading...", randomQuote );
			notifyPopUpShownSignal.addOnce( onPopUpShown );
		}

		private function onPopUpShown():void {
			startLoading();
		}

		private function startLoading():void {
			_time = getTimer();

			var folder:String = CoreSettings.RUNNING_ON_iPAD ? "" : CoreSettings.PAINTING_DATA_FOLDER_NAME + "/";
			_fileName = folder + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION;

			if( CoreSettings.RUNNING_ON_iPAD && CoreSettings.USE_IO_ANE_ON_PAINTING_FILES ) readANE();
			else readAS3();
		}

		private function readAS3():void {
			trace( this, "reading with as3... " + _fileName );
			if( !_as3ReadUtil ) {
				_as3ReadUtil = new BinaryIoUtil( CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP );
			}
			_as3ReadUtil.readBytesAsync( _fileName, onAs3FileRead );
		}

		private function onAs3FileRead( bytes:TrackedByteArray ):void {
			trace( this, "as3 done reading" );
			if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) bytes.uncompress();
			onFileRead( bytes );
		}

		private function readANE():void {
			trace( this, "reading with ane... " + _fileName );
			var bytes:TrackedByteArray = new TrackedByteArray();
	   		if( CoreSettings.USE_COMPRESSION_ON_PAINTING_FILES ) ioAne.extension.readWithDeCompression( bytes, _fileName );
			else ioAne.extension.read( bytes, _fileName );
			trace( this, "ane done reading" );
			onFileRead( bytes );
		}

		private function onFileRead( bytes:TrackedByteArray ):void {

			trace( this, "file read: " + bytes.length );
			ConsoleView.instance.log( this, "done reading - " + String( getTimer() - _time ) );

			// De-serialize.
			_time = getTimer();
			var deserializer:PaintingDataDeserializer = new PaintingDataDeserializer();
			var paintingDataVO:PaintingDataVO = deserializer.deserializePPP( bytes );
			paintingDataVO.loadedFileName = _fileName;
			ConsoleView.instance.log( this, "done de-serializing- " + String( getTimer() - _time ) );
			requestOpenPaintingDataVOSignal.dispatch(paintingDataVO);
			if( _as3ReadUtil ) _as3ReadUtil.dispose();

			hidePopUp();
		}

		private function hidePopUp():void {
			notifyPopUpRemovedSignal.addOnce( onPopUpRemoved );
			requestHidePopUpSignal.dispatch();
		}

		private function onPopUpRemoved():void {
			dispatchComplete( true );
		}
	}
}
