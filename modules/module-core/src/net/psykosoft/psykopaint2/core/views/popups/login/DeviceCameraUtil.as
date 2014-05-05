package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	
	import org.osflash.signals.Signal;

	public class DeviceCameraUtil extends Sprite
	{
		private var _cameraUi:CameraUI;
		private var _imageLoader:Loader;
		private var _stage:Stage;

		public var imageRetrievedSignal:Signal;
		public var selectionCancelledSignal:Signal;
		
		public function DeviceCameraUtil( stage:Stage ) {
			super();

			_stage = stage;

			imageRetrievedSignal = new Signal();
			selectionCancelledSignal = new Signal();
			_cameraUi = new CameraUI();

			_cameraUi.addEventListener( MediaEvent.COMPLETE, imageCaptured );
			_cameraUi.addEventListener( Event.CANCEL, captureCanceled );
			_cameraUi.addEventListener( ErrorEvent.ERROR, cameraError );
		}

		public function dispose():void {

			_cameraUi.removeEventListener( MediaEvent.COMPLETE, imageCaptured );
			_cameraUi.removeEventListener( Event.CANCEL, captureCanceled );
			_cameraUi.removeEventListener( ErrorEvent.ERROR, cameraError );
			_cameraUi = null;

			if(_imageLoader) {
				if(_imageLoader.hasEventListener( IOErrorEvent.IO_ERROR)) {
					_imageLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, asyncImageLoaded );
					_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, cameraError );
				}
				_imageLoader = null;
			}

			_stage = null;

			_stage.autoOrients = false;
		}

		private function cameraError( event:ErrorEvent ):void {
			trace( this, "camera error" );
//			NativeApplication.nativeApplication.exit();
			_stage.autoOrients = false;
		}

		private function captureCanceled( event:Event ):void {
//			trace( this, "canceled" );
//			NativeApplication.nativeApplication.exit();
			_stage.autoOrients = false;
		}

		private function imageCaptured( event:MediaEvent ):void {

//			trace( "Media captured..." );

			var imagePromise:MediaPromise = event.data;

			if( imagePromise.isAsync ) {
//				trace( "Asynchronous media promise." );
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
				_imageLoader.addEventListener( IOErrorEvent.IO_ERROR, cameraError );
				_imageLoader.loadFilePromise( imagePromise );
			}
			else {
//				trace( "Synchronous media promise." );
				_imageLoader.loadFilePromise( imagePromise );
				reportImage();
			}
		}

		private function asyncImageLoaded( event:Event ):void {
//			trace( "Media loaded in memory." );
			reportImage();
		}

		private function reportImage():void {

			_imageLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, asyncImageLoaded );
			_imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, cameraError );

			var bmd:BitmapData = new TrackedBitmapData( _imageLoader.width, _imageLoader.height, false, 0 );
			bmd.draw( _imageLoader );

			imageRetrievedSignal.dispatch( bmd, CameraRollImageOrientation.ROTATION_0 );

			_stage.autoOrients = false;
		}

		public function launch():void {
			_cameraUi.launch( MediaType.IMAGE );

			// Prevents weird orientation behaviour.
			// The presence of the native camera app seems to rotate app's stage which is supposed to be locked. The camera rotates it anyway,
			// but doesn't restore it when returning to the app. Releasing the app's rotation seems to work around the bug.
			_stage.autoOrients = true;
		}
	}
}
