package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;

	import org.osflash.signals.Signal;

	public class DeviceCameraUtil extends Sprite
	{
		private var _cameraUi:CameraUI;
		private var _imageLoader:Loader;

		public var imageRetrievedSignal:Signal;

		public function DeviceCameraUtil() {
			super();

			imageRetrievedSignal = new Signal();

			_cameraUi = new CameraUI();

			_cameraUi.addEventListener( MediaEvent.COMPLETE, imageCaptured );
			_cameraUi.addEventListener( Event.CANCEL, captureCanceled );
			_cameraUi.addEventListener( ErrorEvent.ERROR, cameraError );
		}

		public function dispose():void {
			_cameraUi.removeEventListener( MediaEvent.COMPLETE, imageCaptured );
			_cameraUi.removeEventListener( Event.CANCEL, captureCanceled );
			_cameraUi.removeEventListener( ErrorEvent.ERROR, cameraError );
		}

		private function cameraError( event:ErrorEvent ):void {
			trace( this, "camera error" );
//			NativeApplication.nativeApplication.exit();
		}

		private function captureCanceled( event:Event ):void {
			trace( this, "canceled" );
//			NativeApplication.nativeApplication.exit();
		}

		private function imageCaptured( event:MediaEvent ):void {

			trace( "Media captured..." );

			var imagePromise:MediaPromise = event.data;

			if( imagePromise.isAsync ) {
				trace( "Asynchronous media promise." );
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
				_imageLoader.addEventListener( IOErrorEvent.IO_ERROR, cameraError );
				_imageLoader.loadFilePromise( imagePromise );
			}
			else {
				trace( "Synchronous media promise." );
				_imageLoader.loadFilePromise( imagePromise );
				reportImage();
			}
		}

		private function asyncImageLoaded( event:Event ):void {
			trace( "Media loaded in memory." );
			reportImage();
		}

		private function reportImage():void {

			_imageLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, asyncImageLoaded );
			_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, cameraError );

			var bmd:BitmapData = new BitmapData( _imageLoader.width, _imageLoader.height, false, 0 );
			bmd.draw( _imageLoader );

			imageRetrievedSignal.dispatch( bmd );
		}

		public function launch():void {
			_cameraUi.launch( MediaType.IMAGE )
		}
	}
}
