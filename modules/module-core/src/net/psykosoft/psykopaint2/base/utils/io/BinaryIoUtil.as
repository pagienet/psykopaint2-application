package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.events.Event;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class BinaryIoUtil
	{
		private var _fileStream:FileStream;
		private var _onWriteCompleteCallback:Function;
		private var _rootFile:File;
		private var _fileName:String;

		public static const STORAGE_TYPE_DESKTOP:String = "desktop";
		public static const STORAGE_TYPE_IOS:String = "ios";

		public function BinaryIoUtil( storageType:String ) {
			super();
			switch( storageType ) {
				case STORAGE_TYPE_DESKTOP: {
					_rootFile = File.desktopDirectory;
					break;
				}
				case STORAGE_TYPE_IOS: {
					_rootFile = File.applicationStorageDirectory;
					break;
				}
				default: {
					throw new Error( "Unknown storage type, see static properties in BinaryIoUtil.as." );
				}
			}
		}

		public function writeBytesSync( fileName:String, bytes:ByteArray ):void {
			var file:File = _rootFile.resolvePath( fileName );
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( bytes );
			fileStream.close();
		}

		public function writeBytesAsync( fileName:String, bytes:ByteArray, onComplete:Function ):void {
			_onWriteCompleteCallback = onComplete;
			_fileName = fileName;
			trace( this, "writing bytes - filename: " + _fileName + ", numBytes: " + bytes.length );
			var file:File = _rootFile.resolvePath( fileName );
			_fileStream = new FileStream();
			_fileStream.addEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			_fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onWriteBytesAsyncProgress );
			_fileStream.openAsync( file, FileMode.WRITE );
			_fileStream.writeBytes( bytes );
		}

		private function onWriteBytesAsyncProgress( event:OutputProgressEvent ):void {
			trace( this, "writing bytes progress - filename: " + _fileName + ", bytes pending: " + event.bytesPending );
			if( event.bytesPending == 0 ) {
				_fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onWriteBytesAsyncProgress );
				_fileStream.close();
			}
		}

		private function onWriteBytesAsyncClosed( event:Event ):void {
			trace( this, "done writing bytes - filename: " + _fileName );
			_fileStream.removeEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			if( _onWriteCompleteCallback ) {
				_onWriteCompleteCallback();
			}
		}
	}
}
