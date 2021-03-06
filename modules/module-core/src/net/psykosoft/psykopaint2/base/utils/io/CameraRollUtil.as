package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.Bitmap;
	import flash.display.BitmapDataChannel;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.media.MediaPromise;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import away3d.bounds.NullBounds;
	
	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.IFD;
	
	import org.osflash.signals.Signal;

	public class CameraRollUtil
	{
		private var _cameraRoll:CameraRoll;
		private var _imageLoader:Loader;

		public var imageRetrievedSignal:Signal;
		public var selectionCancelledSignal:Signal;
		private var exifData:Array;
		private var mediaPromise:MediaPromise;
		private var imageBytes:ByteArray;
		private var i:int=0;

		public function CameraRollUtil() {
			super();

			imageRetrievedSignal = new Signal();
			selectionCancelledSignal = new Signal();
			_cameraRoll = new CameraRoll();
			_cameraRoll.addEventListener( MediaEvent.SELECT, onPhotoComplete );
			_cameraRoll.addEventListener( Event.CANCEL, browseCanceled );
			_cameraRoll.addEventListener( ErrorEvent.ERROR, mediaError );

		}
		
		protected function mediaError(event:ErrorEvent):void
		{
			trace("error:"+event.errorID+"=>"+event.text);
			
		}		
		
		private function onPhotoComplete(e:MediaEvent):void
		{
			_cameraRoll.removeEventListener(Event.SELECT, onPhotoComplete);
			
			mediaPromise = e.data;
			
			/*_imageLoader = new Loader();
			_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
			_imageLoader.loadFilePromise(mediaPromise);*/
			
			
			imageBytes = new ByteArray();
			if (this.mediaPromise.isAsync)
			{
				var mediaDispatcher:IEventDispatcher = this.mediaPromise.open() as IEventDispatcher;
				
				mediaDispatcher.addEventListener(ProgressEvent.PROGRESS, onMediaPromiseProgress);
				mediaDispatcher.addEventListener(Event.COMPLETE, onMediaPromiseComplete);
			}
			else
			{
				var input:IDataInput = this.mediaPromise.open();
				
				input.readBytes(imageBytes, 0, input.bytesAvailable);
				mediaPromise.close();
				imageSelected();
			}
			
		}
		
		private function onMediaPromiseProgress(e:ProgressEvent):void
		{
			var input:IDataInput = e.target as IDataInput;
			input.readBytes(imageBytes, imageBytes.length, input.bytesAvailable);
			input = null;
		}
		
		private function onMediaPromiseComplete(e:Event):void
		{
			IEventDispatcher(e.target).removeEventListener(ProgressEvent.PROGRESS, onMediaPromiseProgress);
			IEventDispatcher(e.target).removeEventListener(Event.COMPLETE, onMediaPromiseComplete);
			mediaPromise.close();
			imageSelected();
		}
		
		private function parse(eb:ByteArray):void
		{
			var exifInfo:ExifInfo = new ExifInfo(eb);
			exifData = [];
			this.iterateTags(exifInfo.ifds.primary, exifData);
			/*
			this.iterateTags(exifInfo.ifds.exif, exifData);
			this.iterateTags(exifInfo.ifds.gps, exifData);
			this.iterateTags(exifInfo.ifds.interoperability, exifData);
			this.iterateTags(exifInfo.ifds.thumbnail, exifData);
			*/
		}
		
		private function iterateTags(ifd:IFD, exifData:Array):void
		{
			if (!ifd) return;
			for (var entry:String in ifd)
			{
				if (entry == "MakerNote") continue;
				exifData.push(entry + ": " + ifd[entry]);
			}
		}
		
		private function imageSelected():void {

			parse(imageBytes);
			
			
			
			trace( this, "media selected..." );
			_imageLoader = new Loader();
			_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
			imageBytes.position = 0;
			_imageLoader.loadBytes(imageBytes);
			/*
			if( mediaPromise.isAsync ) {
				trace( "Asynchronous media promise." );
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
				_imageLoader.addEventListener( IOErrorEvent.IO_ERROR, loadError );
				_imageLoader.loadFilePromise( mediaPromise );
			}
			else {
				trace( "Synchronous media promise." );
				_imageLoader.loadFilePromise( mediaPromise );
				reportImage();
			}
			*/
			
		}

		private function asyncImageLoaded( event:Event ):void {
			trace( this, "Media loaded in memory." );
			reportImage();
		}

		private function loadError( event:ErrorEvent ):void {
			trace( this, "camera error" );
//			NativeApplication.nativeApplication.exit();
		}

		private function reportImage():void {

			_imageLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, asyncImageLoaded );
			_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, loadError );

			imageBytes.clear();
			imageBytes = null;
			
			
			//imageRetrievedSignal.dispatch( ((_imageLoader.content) as Bitmap).bitmapData,parseInt(exifData[0].split(": ")[1]));
			imageRetrievedSignal.dispatch( ((_imageLoader.content) as Bitmap).bitmapData,1);
		}

		public function dispose():void {
			//CLEAR IMAGE LOADER:
			if(_imageLoader){
				_imageLoader.unload();
				_imageLoader = null;
			}
			_cameraRoll.removeEventListener( MediaEvent.SELECT, imageSelected );
			_cameraRoll.removeEventListener( Event.CANCEL, browseCanceled );
		}

		private function browseCanceled( event:Event ):void {
			trace( this, "canceled" );
			selectionCancelledSignal.dispatch();
		}

		public function launch( launcherRect:Rectangle, width:Number, height:Number ):void {
			
			//CLEAR IMAGE LOADER:
			if(_imageLoader){
				_imageLoader.unload();
				_imageLoader = null;
			}
			
			var options:CameraRollBrowseOptions = new CameraRollBrowseOptions();
			options.origin = launcherRect;
			//options.width = width;
			options.height = height;
			_cameraRoll.browseForImage( options );
		}
	}
}
