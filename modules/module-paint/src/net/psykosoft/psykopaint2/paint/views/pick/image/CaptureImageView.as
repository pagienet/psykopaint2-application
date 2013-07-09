package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;
	import flash.media.Camera;
	import flash.media.Video;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class CaptureImageView extends ViewBase
	{
		private var _activeCameraIndex:uint;
		private var _currentCamera:Camera = new Camera();
		private var _video:Video;
		private var _bmd:BitmapData;

		public function CaptureImageView() {
			super();
		}

		override protected function onEnabled():void {
			_video = new Video( 512, 384 );
			_video.x = 256;
			_video.y = 90;
			_video.smoothing = true;

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
			_bmd = new BitmapData( 1024, 768, false, 0 );
			_currentCamera.drawToBitmapData( _bmd );
			_video.attachCamera( null );
		}

		public function play():void {
			_video.attachCamera( _currentCamera );
		}

		public function takeSnapshot():BitmapData {
			return _bmd;
		}

		public function flipCamera():void {
			setCameraByIndex( _activeCameraIndex == 0 ? 1 : 0 );
		}
	}
}
