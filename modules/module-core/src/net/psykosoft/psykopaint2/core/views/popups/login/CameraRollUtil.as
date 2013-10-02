package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.media.MediaPromise;

	import org.osflash.signals.Signal;

	public class CameraRollUtil
	{
		private var _cameraRoll:CameraRoll;
		private var _imageLoader:Loader;

		public var imageRetrievedSignal:Signal;

		public function CameraRollUtil() {
			super();

			imageRetrievedSignal = new Signal();

			_cameraRoll = new CameraRoll();
			_cameraRoll.addEventListener( MediaEvent.SELECT, imageSelected );
			_cameraRoll.addEventListener( Event.CANCEL, browseCanceled );
		}

		private function imageSelected( event:MediaEvent ):void {

			trace( this, "media selected..." );

			var imagePromise:MediaPromise = event.data;

			if( imagePromise.isAsync ) {
				trace( "Asynchronous media promise." );
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
				_imageLoader.addEventListener( IOErrorEvent.IO_ERROR, loadError );
				_imageLoader.loadFilePromise( imagePromise );
			}
			else {
				trace( "Synchronous media promise." );
				_imageLoader.loadFilePromise( imagePromise );
				reportImage();
			}
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

			var bmd:BitmapData = new BitmapData( _imageLoader.width, _imageLoader.height, false, 0 );
			bmd.draw( _imageLoader );

			imageRetrievedSignal.dispatch( bmd );
		}

		public function dispose():void {
			_cameraRoll.removeEventListener( MediaEvent.SELECT, imageSelected );
			_cameraRoll.removeEventListener( Event.CANCEL, browseCanceled );
		}

		private function browseCanceled( event:Event ):void {
			trace( this, "canceled" );
		}

		public function launch( launcherRect:Rectangle, width:Number, height:Number ):void {
			var options:CameraRollBrowseOptions = new CameraRollBrowseOptions();
			options.origin = launcherRect;
			options.width = width;
			options.height = height;
			_cameraRoll.browseForImage( options );
		}
	}
}
