package net.psykosoft.psykopaint2.core.commands
{

	import flash.events.Event;
	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.FolderReadUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;

	import robotlegs.bender.framework.api.IContext;

	public class RetrievePaintingDataCommand extends TracingCommand
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var model:PaintingModel;

		private var _currentFileBeingLoaded:File;
		private var _currentVoBeingDeSerialized:PaintingInfoVO;
		private var _paintingFiles:Vector.<File>;
		private var _numPaintingFiles:uint;
		private var _indexOfPaintingFileBeingRead:uint;
		private var _paintingVos:Vector.<PaintingInfoVO>;

		public function RetrievePaintingDataCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Read files in app data folder or bundle.
			var files:Array;
			if( CoreSettings.RUNNING_ON_iPAD ) {
				files = FolderReadUtil.readFilesInIosFolder( CoreSettings.PAINTING_DATA_FOLDER_NAME );
			}
			else {
				files = FolderReadUtil.readFilesInDesktopFolder( CoreSettings.PAINTING_DATA_FOLDER_NAME );
			}
			var len:uint = files.length;
			trace( this, "found files in paint data " + len + ": " );

			// Sweep files and focus on the ones that have the .psy extension, which represents paintings.
			_paintingFiles = new Vector.<File>();
			for( var i:uint; i < len; i++ ) {
				var file:File = files[ i ];
				trace( "  file: " + file.name );
				if( file.name.indexOf( PaintingSerializer.PAINTING_INFO_FILE_EXTENSION ) != -1 ) {
					_paintingFiles.push( file );
				}
			}
			_numPaintingFiles = _paintingFiles.length;

			// Detain command and start reading the painting files.
			if( _numPaintingFiles > 0 ) {
				trace( this, "starting to read painting files... ( " + _numPaintingFiles + " )" );
				context.detain( this );
				_paintingVos = new Vector.<PaintingInfoVO>();
				readNextFile();
			}
		}

		private function readNextFile():void {
			_currentFileBeingLoaded = _paintingFiles[ _indexOfPaintingFileBeingRead ];
			trace( this, "reading file: " + _currentFileBeingLoaded.name + "..." );
			_currentFileBeingLoaded.addEventListener( Event.COMPLETE, onFileRead );
			_currentFileBeingLoaded.load();
		}

		private function onFileRead( event:Event ):void {
			_currentFileBeingLoaded.removeEventListener( Event.COMPLETE, onFileRead );

			// Read the contents of the file to a value object.
			trace( this, "file read: " + _currentFileBeingLoaded.data.length + " bytes" );
			_currentVoBeingDeSerialized = new PaintingInfoVO();

			trace( this, "de-serializing vo..." );
			try {
				var serializer:PaintingSerializer = new PaintingSerializer();
				serializer.deSerializePaintingVoInfoAsync( _currentFileBeingLoaded.data, _currentVoBeingDeSerialized, onVoDeSerialized );
			} catch( error:Error ) {
				trace( this, "***WARNING*** Error de-serializing file: " + _currentFileBeingLoaded.nativePath );
			}
		}

		private function onVoDeSerialized():void {
			trace( this, "produced vo: " + _currentVoBeingDeSerialized );
			_paintingVos.push( _currentVoBeingDeSerialized );

			// Continue reading next file.
			_indexOfPaintingFileBeingRead++;
			if( _indexOfPaintingFileBeingRead < _numPaintingFiles ) {
				readNextFile();
			}
			else {
				trace( this, "all painting files read. Retrieved " + _paintingVos.length + " usable painting files." );
				if( _paintingVos.length > 0 ) model.setPaintingData( _paintingVos );
				context.release();
			}
		}
	}
}
