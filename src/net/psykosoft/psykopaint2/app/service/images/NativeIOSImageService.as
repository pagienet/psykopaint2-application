package net.psykosoft.psykopaint2.app.service.images
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraRoll;
	import flash.media.MediaPromise;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.getTimer;

	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.ExifUtils;

	import org.osflash.signals.Signal;

	public class NativeIOSImageService implements IImageService
	{
		private var _cameraRoll:CameraRoll;
		private var _loader:Loader;
		private var _timeStamp:int;
		private var _dataSource:IDataInput;
		private var _eventSource:IEventDispatcher;
		private var _imageBytes:ByteArray;

		private var _imageLoadedSignal:Signal;

		public function NativeIOSImageService() {
			super();
			_cameraRoll = new CameraRoll();
			_cameraRoll.addEventListener( MediaEvent.SELECT, onMediaSelected );
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );
			_imageLoadedSignal = new Signal();
		}

		public function disposeService():void {
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onImageLoaded );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );
			_loader = null;
			_cameraRoll.removeEventListener( MediaEvent.SELECT, onMediaSelected );
			_cameraRoll = null;
			if( _dataSource ) {
				_dataSource = null;
			}
			if( _eventSource ) {
				if( _eventSource.hasEventListener( Event.COMPLETE ) ) {
					_eventSource.removeEventListener( Event.COMPLETE, onDataComplete );
				}
				_eventSource = null;
			}
			if( _imageBytes ) {
			 	_imageBytes = null;
			}
		}

		public function loadThumbnails():void {
			throw new Error( this, "this service does not provide thumbnails." );
		}

		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}

		public function getThumbnailsLoadedSignal():Signal {
			throw new Error( this, "this service does not provide thumbnails." );
		}

		public function loadFullImage( id:String ):void {
			_cameraRoll.browseForImage();
		}

		private function onMediaSelected( event:MediaEvent ):void {
			trace( this, "Media selected..." );
			_timeStamp = getTimer();
			var imagePromise:MediaPromise = event.data;
			_dataSource = imagePromise.open();

			if( imagePromise.isAsync ) {
				_eventSource = _dataSource as IEventDispatcher;
				trace( this, _eventSource );
				_eventSource.addEventListener( Event.COMPLETE, onDataComplete );
			}
			else {
				readMediaData();
			}
		}

		private function onDataComplete( event:Event ):void {
			trace( this, "Data load complete " + (getTimer() - _timeStamp) + " ms" );
			_timeStamp = getTimer();
			_eventSource.removeEventListener( Event.COMPLETE, onDataComplete );
			readMediaData();
		}

		private function readMediaData():void {
			_imageBytes = new ByteArray();
			_dataSource.readBytes( _imageBytes );
			_dataSource = null;
			_eventSource = null;
			_imageBytes.position = 0;
			_loader.loadBytes( _imageBytes );

		}

		private function onImageLoaded( event:Event ):void {
			trace( this, "image loaded: " + _loader.width + ", " + _loader.height + " " + (getTimer() - _timeStamp) + " ms" );
			_timeStamp = getTimer();
			var image:BitmapData;
			//var extractedJPEGData:ByteArray = ExifUtils.extractJpegFromLoader(_loader.contentLoaderInfo.bytes);
			//if ( extractedJPEGData != null )
			//{
			_imageBytes.position = 0;
			var exif:ExifInfo = new ExifInfo( _imageBytes );
			if( exif.isValid ) {
				image = ExifUtils.getEyeOrientedBitmapData( (_loader.content as Bitmap).bitmapData, exif.ifds );
			}
			trace( this, "image complete: " + (getTimer() - _timeStamp) + " ms" );

			if( image == null ) image = (_loader.content as Bitmap).bitmapData;

			_imageLoadedSignal.dispatch( image );

			_imageBytes = null;
			//trace( this, "bitmap data created: " + image.width + ", " + image.height );

		}

		private function onImageLoadError( event:IOErrorEvent ):void {
			trace( this, event.toString() );
			_imageBytes = null;
		}
	}
}
