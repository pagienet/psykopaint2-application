package net.psykosoft.psykopaint2.app.service.images
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	import jp.shichiseki.exif.ExifInfo;

	import jp.shichiseki.exif.ExifUtils;

	import org.osflash.signals.Signal;

	public class DesktopImageService implements IImageService
	{
		private var _file:File;
		private var _loader:Loader;

		private var _imageLoadedSignal:Signal;

		public function DesktopImageService() {
			super();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
			_imageLoadedSignal = new Signal();
		}

		public function loadFullImage( id:String ):void {
			_file = new File( File.desktopDirectory.url );
			_file.addEventListener( Event.SELECT, onFileSelect );
			var fileFilter:FileFilter = new FileFilter( "Images", "*.jpg;*.jpeg;*.gif;*.png" );
			_file.browseForOpen( "Open an image file", [ fileFilter ] );
		}

		public function loadThumbnails():void {
			throw new Error( this, "this service does not provide thumbnails." );
		}

		public function disposeService():void {
		 	if( _file.hasEventListener( Event.SELECT ) ) {
				_file.removeEventListener( Event.SELECT, onFileSelect );
			}
			_file = null;
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onImageLoaded );
			_loader = null;
		}

		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}

		public function getThumbnailsLoadedSignal():Signal {
			throw new Error( this, "this service does not provide thumbnails." );
		}

		private function onImageLoaded( event:Event ):void {
			var image:BitmapData;
			var extractedJPEGData:ByteArray = ExifUtils.extractJpegFromLoader(_loader.contentLoaderInfo.bytes);
			if ( extractedJPEGData != null )
			{
				var exif:ExifInfo = new ExifInfo(extractedJPEGData);
				if ( exif.isValid ) {
					image = ExifUtils.getEyeOrientedBitmapData( (_loader.content as Bitmap).bitmapData, exif.ifds );
				}
			}
			if ( image == null ) image = (_loader.content as Bitmap).bitmapData;
			_imageLoadedSignal.dispatch( image );
		}

		private function onFileSelect( event:Event ):void {
			_file.removeEventListener( Event.SELECT, onFileSelect );
			var context:LoaderContext = new LoaderContext();
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			_loader.load( new URLRequest( _file.url ), context );
		}
	}
}
