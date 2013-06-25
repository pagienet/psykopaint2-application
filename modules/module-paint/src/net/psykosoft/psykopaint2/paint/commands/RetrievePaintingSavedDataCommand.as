package net.psykosoft.psykopaint2.paint.commands
{

	import flash.events.Event;
	import flash.filesystem.File;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopFolderReadUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;
	import net.psykosoft.psykopaint2.paint.model.PaintingDataModel;

	import robotlegs.bender.framework.api.IContext;

	public class RetrievePaintingSavedDataCommand extends TracingCommand
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var model:PaintingDataModel;

		private var _currentFileBeingLoaded:File;
		private var _paintingFiles:Vector.<File>;
		private var _numPaintingFiles:uint;
		private var _indexOfPaintingFileBeingRead:uint;
		private var _paintingVos:Vector.<PaintingVO>;
		private var _currentVoBeingDeSerialized:PaintingVO;

		public function RetrievePaintingSavedDataCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Read files in app data folder or bundle.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else {

				// Read all files in data folder.
				var files:Array = DesktopFolderReadUtil.readFilesInFolder( PaintSettings.desktopDataFolderName );
				var len:uint = files.length;
				trace( this, "found files in paint data " + len + ": " );

				// Sweep files and focus on the ones that have the .psy extension, which represents paintings.
				_paintingFiles = new Vector.<File>();
				for( var i:uint; i < len; i++ ) {
					var file:File = files[ i ];
					trace( "  file: " + file.name );
					if( file.name.indexOf( PaintSettings.paintingFileExtension ) != -1 ) {
						_paintingFiles.push( file );
					}
				}
				_numPaintingFiles = _paintingFiles.length;

				// Detain command and start reading the painting files.
				if( _numPaintingFiles > 0 ) {
					trace( this, "starting to read painting files... ( " + _numPaintingFiles + " )" );
					context.detain( this );
					_paintingVos = new Vector.<PaintingVO>();
					readNextFile();
				}
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
			_currentVoBeingDeSerialized = new PaintingVO();
			_paintingVos.push( _currentVoBeingDeSerialized );
			trace( this, "de-serializing vo..." );
			_currentVoBeingDeSerialized.deSerialize( _currentFileBeingLoaded.data, onVoDeSerialized );
		}

		private function onVoDeSerialized():void {
			trace( this, "vo de-serialized, id: " + _currentVoBeingDeSerialized.id );
			// Continue reading next file.
			_indexOfPaintingFileBeingRead++;
			if( _indexOfPaintingFileBeingRead < _numPaintingFiles ) {
				readNextFile();
			}
			else {
				trace( this, "all painting files read." );
				model.setPaintingData( _paintingVos );
				context.release();
			}
		}
	}
}
