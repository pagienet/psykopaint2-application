package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class BinaryIoUtil
	{
		private var _fileStream:FileStream;
		private var _onWriteCompleteCallback:Function;
		private var _onReadCompleteCallback:Function;
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
					_rootFile = File.documentsDirectory;
					break;
				}
				default: {
					throw new Error( "Unknown storage type, see static properties in BinaryIoUtil.as." );
				}
			}
		}

		// ---------------------------------------------------------------------
		// Write sync.
		// ---------------------------------------------------------------------

		public function writeBytesSync( fileName:String, bytes:ByteArray ):void {
			trace( this, "sync writing bytes - filename: " + fileName + ", numBytes: " + bytes.length );
			var file:File = _rootFile.resolvePath( fileName );
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeBytes( bytes );
			fileStream.close();
		}

		// ---------------------------------------------------------------------
		// Write Async.
		// ---------------------------------------------------------------------

		public function writeBytesAsync( fileName:String, bytes:ByteArray, onComplete:Function ):void {
			_onWriteCompleteCallback = onComplete;
			_fileName = fileName;
			trace( this, "async writing bytes - filename: " + _fileName + ", numBytes: " + bytes.length );
			var file:File = _rootFile.resolvePath( fileName );
			_fileStream = new FileStream();
			addAsyncWriteListeners();
			_fileStream.openAsync( file, FileMode.WRITE );
			_fileStream.writeBytes( bytes );
		}

		private function onWriteBytesAsyncError( event:IOErrorEvent ):void {
			trace( this, "async writing bytes error - filename: " + _fileName + ", details: " + event.errorID + ", " + event.text );
			removeAsyncWriteListeners();
			_fileStream = null;
		}

		private function onWriteBytesAsyncProgress( event:OutputProgressEvent ):void {
			trace( this, "async writing bytes progress - filename: " + _fileName + ", bytes pending: " + event.bytesPending );
			if( event.bytesPending == 0 ) _fileStream.close();
		}

		private function onWriteBytesAsyncClosed( event:Event ):void {
			trace( this, "async writing bytes done - filename: " + _fileName );
			_fileStream.removeEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			if( _onWriteCompleteCallback != null) _onWriteCompleteCallback();
			_onWriteCompleteCallback = null;
			removeAsyncWriteListeners();
			_fileStream = null;
		}

		private function addAsyncWriteListeners():void {
			_fileStream.addEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			_fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onWriteBytesAsyncProgress );
			_fileStream.addEventListener( IOErrorEvent.IO_ERROR, onWriteBytesAsyncError );
		}

		private function removeAsyncWriteListeners():void {
			_fileStream.removeEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			_fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onWriteBytesAsyncProgress );
			_fileStream.removeEventListener( IOErrorEvent.IO_ERROR, onWriteBytesAsyncError );
		}

		// ---------------------------------------------------------------------
		// Read Async.
		// ---------------------------------------------------------------------

		public function readBytesAsync( fileName:String, onComplete:Function ):void {
	   		_onReadCompleteCallback = onComplete;
			_fileName = fileName;
			trace( this, "async reading file - filename: " + _fileName );
			var file:File = _rootFile.resolvePath( fileName );
			_fileStream = new FileStream();
			addReadListeners();
			_fileStream.openAsync( file, FileMode.READ );
		}

		private function onReadBytesAsyncError( event:IOErrorEvent ):void {
			trace( this, "async reading bytes error - filename: " + _fileName + ", details: " + event.errorID + ", " + event.text );
			removeReadListeners();
			_fileStream = null;
		}

		private function onReadBytesAsyncProgress( event:OutputProgressEvent ):void {
			trace( this, "async reading bytes progress - filename: " + _fileName + ", bytes pending: " + event.bytesPending );
		}

		private function onReadBytesAsyncComplete( event:Event ):void {
			trace( this, "async reading bytes done - filename: " + _fileName );
			var bytes:ByteArray = new ByteArray();
			_fileStream.readBytes( bytes, 0, _fileStream.bytesAvailable );
			if( _onReadCompleteCallback != null) _onReadCompleteCallback( bytes );
			_onReadCompleteCallback = null;
			removeReadListeners();
			_fileStream = null;
		}

		private function addReadListeners():void {
			_fileStream.addEventListener( Event.COMPLETE, onReadBytesAsyncComplete );
			_fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onReadBytesAsyncProgress );
			_fileStream.addEventListener( IOErrorEvent.IO_ERROR, onReadBytesAsyncError );
		}

		private function removeReadListeners():void {
			if( !_fileStream ) return;
			if( _fileStream.hasEventListener( Event.COMPLETE ) ) _fileStream.removeEventListener( Event.COMPLETE, onReadBytesAsyncComplete );
			if( _fileStream.hasEventListener( OutputProgressEvent.OUTPUT_PROGRESS ) ) _fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onReadBytesAsyncProgress );
			if( _fileStream.hasEventListener( IOErrorEvent.IO_ERROR ) ) _fileStream.removeEventListener( IOErrorEvent.IO_ERROR, onReadBytesAsyncError );
		}

		public function dispose():void {
			removeReadListeners();
			_onReadCompleteCallback = null;
			_onWriteCompleteCallback = null;
			if( _fileStream ) _fileStream.close();
			_rootFile = null;
			_fileStream = null;
		}
	}
}
