package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;
	import flash.media.Camera;
	import flash.media.Video;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class CaptureImageView extends ViewBase
	{
		private var _camera:Camera = new Camera();
		private var _video:Video;
		private var _bmd:BitmapData;

		public function CaptureImageView() {
			super();
		}

		override protected function onEnabled():void {
			_camera = Camera.getCamera();
			if( _camera != null ) {
				_camera.setMode( 1024, 768, 15 );
				_video = new Video( 1024, 768 );
				_video.attachCamera( _camera );
				_video.smoothing = true;
			}
			addChild( _video );
		}

		override protected function onDisabled():void {
			//TODO: check if anything else needs to be disposed.
			_camera = null;
			_video = null;
			removeChild( _video )
		}

		public function pause():void {
			_bmd = new BitmapData( 1024, 768, false, 0 );
			_camera.drawToBitmapData( _bmd );
			_video.attachCamera( null );
		}

		public function play():void {
			_video.attachCamera( _camera );
		}

		public function takeSnapshot():BitmapData {
			return _bmd;
		}

		public function flipCamera():void {
			//TODO.
		}
	}
}
