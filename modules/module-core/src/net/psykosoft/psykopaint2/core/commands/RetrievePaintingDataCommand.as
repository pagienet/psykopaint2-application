package net.psykosoft.psykopaint2.core.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;

	import net.psykosoft.psykopaint2.base.utils.io.FolderReadUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;

	public class RetrievePaintingDataCommand extends AsyncCommand
	{
		[Inject]
		public var paintingModel:PaintingModel;

		private var _paintingFileNames:Vector.<String>;
		private var _numPaintingFiles:uint;
		private var _indexOfPaintingFileBeingRead:uint;
		private var _paintingVos:Vector.<PaintingInfoVO>;
		private var _readUtil:BinaryIoUtil;

		public function RetrievePaintingDataCommand() {
			super();
		}

		override public function execute():void {

			trace( this, "execute()" );

			_paintingVos = new Vector.<PaintingInfoVO>();

			// Read files in app data folder or bundle.
			var files:Array;
			if( CoreSettings.RUNNING_ON_iPAD ) files = FolderReadUtil.readFilesInIosFolder( CoreSettings.PAINTING_DATA_FOLDER_NAME );
			else files = FolderReadUtil.readFilesInDesktopFolder( CoreSettings.PAINTING_DATA_FOLDER_NAME );
			var len:uint = files.length;
			trace( this, "found files in paint data: " + len );

			// Sweep files and focus on the ones that have the .psy extension, which represents paintings.
			_paintingFileNames = new Vector.<String>();
			for( var i:uint; i < len; i++ ) {
				var file:File = files[ i ];
				trace( "  file: " + file.name );
				if( file.name.indexOf( PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION ) != -1 ) {
					_paintingFileNames.push( file.name );
				}
			}
			_numPaintingFiles = _paintingFileNames.length;

			// Start reading the painting files...
			if( _numPaintingFiles > 0 ) {
				trace( this, "starting to read painting files... ( " + _numPaintingFiles + " )" );
				readNextFile();
			}
			else {
				paintingModel.setPaintingCollection( _paintingVos );
				dispatchComplete( true );
			}
		}

		private function readNextFile():void {
			if( !_readUtil ) {
				_readUtil = new BinaryIoUtil( CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP );
			}
			var fileName:String = _paintingFileNames[ _indexOfPaintingFileBeingRead ];
			trace( this, "reading file: " + fileName + "..." );
			_readUtil.readBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + fileName, onFileRead );
		}

		private function onFileRead( readBytes:ByteArray ):void {

			// Read the contents of the file to a value object.
			trace( this, "file read: " + readBytes.length + " bytes" );

			trace( this, "de-serializing vo..." );
			try {
				var deserializer:PaintingInfoDeserializer = new PaintingInfoDeserializer();
				deserializer.addEventListener(Event.COMPLETE, onVODeserialized);
				deserializer.deserialize( readBytes );
			} catch( error:Error ) {
				trace( this, "***WARNING*** Error de-serializing file." );
			}
		}

		private function onVODeserialized(event : Event):void {
			var deserializer : PaintingInfoDeserializer = PaintingInfoDeserializer(event.target);
			var paintingInfoVO : PaintingInfoVO = deserializer.paintingInfoVO;
			deserializer.removeEventListener(Event.COMPLETE, onVODeserialized);
			trace( this, "produced vo: " + paintingInfoVO );
			_paintingVos.push( paintingInfoVO );

			// Continue reading next file.
			_indexOfPaintingFileBeingRead++;
			if( _indexOfPaintingFileBeingRead < _numPaintingFiles ) {
				readNextFile();
			}
			else {
				trace( this, "all painting files read. Retrieved " + _paintingVos.length + " usable painting files." );
				if( _paintingVos.length > 0 ) paintingModel.setPaintingCollection( _paintingVos );
				_readUtil = null;
				dispatchComplete( true );
			}
		}
	}
}
