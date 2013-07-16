package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Video;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class CaptureImageView extends ViewBase
	{
		// Declared in Flash.
		public var handHolding:Sprite;
		public var photoCamera:Sprite;

		private var _activeCameraIndex:uint;
		private var _currentCamera:Camera = new Camera();
		private var _video:Video;
		private var _bmd:BitmapData;

		public function CaptureImageView() {
			super();
		}

		override protected function onEnabled():void {
			_video = new Video( 512, 384 );
			_video.x = 383;
			_video.y = 105;
			_video.smoothing = true;

			handHolding.visible = false;
			photoCamera.visible = true;

			setCameraByIndex( 0 );
		}

		private function setCameraByIndex( index:uint ):void {
			if( _currentCamera ) {
				// TODO: check if we need to stop the camera or something
			}
			_currentCamera = Camera.getCamera( String( index ) );
			if( _currentCamera ) {
				_currentCamera.setMode( 1024, 768, 15, false );
				_video.attachCamera( _currentCamera );
				//TODO: set camera quality?
				addChild( _video );
			}
			_activeCameraIndex = index;
		}

		override protected function onDisabled():void {
			//TODO: check if anything else needs to be disposed.
			_currentCamera = null;
			removeChild( _video );
			_video = null;
		}

		public function pause():void {
			_bmd = new TrackedBitmapData( 1024, 768, false, 0 );
			_currentCamera.drawToBitmapData( _bmd );
			trace(_bmd, "bitmap data captured by camera");
			_video.attachCamera( null );

			handHolding.visible = true;
			photoCamera.visible = false;
		}

		public function play():void {
			_video.attachCamera( _currentCamera );

			handHolding.visible = false;
			photoCamera.visible = true;
		}

		public function takeSnapshot():BitmapData {
			return _bmd;
		}

		public function flipCamera():void {
			setCameraByIndex( _activeCameraIndex == 0 ? 1 : 0 );
		}
	}
}
