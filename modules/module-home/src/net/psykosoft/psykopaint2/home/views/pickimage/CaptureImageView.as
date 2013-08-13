package net.psykosoft.psykopaint2.home.views.pickimage
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class CaptureImageView extends ViewBase
	{
		// Declared in Flash.
		public var photoCamera:Sprite;

		private var _activeCameraIndex:uint;
		private var _currentCamera:Camera = new Camera();
		private var _video:Video;
		private var _bmd:BitmapData;
		private var _snapshot:Bitmap;
		private var _videoPos:Point;
		private var _snapshotPos:Point;
		private var _moveToSideBy:uint;
		private var _speed:uint;

		public function CaptureImageView() {
			super();
		}

		override protected function onDisposed():void {

			clearAllTweens();

			if( _snapshot && _snapshot.bitmapData ) {
				_snapshot.bitmapData.dispose();
			}

			_video.attachCamera( null );

		}

		override protected function onEnabled():void {

			_moveToSideBy = 300;
			_speed = 1;

			_video = new Video( 512, 384 );
			_videoPos = new Point( 383, 105 );
			cameraInitPos();
			_video.smoothing = true;
			addChild( _video );

			_snapshot = new Bitmap();
			_snapshot.visible = false;
			_snapshotPos = new Point( 250, 82 );
			snapshotInitPos();
			_snapshot.scaleX = _snapshot.scaleY = 1 / CoreSettings.GLOBAL_SCALING;
			addChild( _snapshot );

			cameraEnter();
			setCameraByIndex( 0 );
		}

		override protected function onDisabled():void {
			//TODO: check if anything else needs to be disposed.
			_currentCamera = null;
			removeChild( _video );
			_video.attachCamera( null );
			_video = null;
			_snapshot.visible = false;
			clearAllTweens();
		}

		private function setCameraByIndex( index:uint ):void {
			if( _currentCamera ) {
				// TODO: check if we need to stop the camera or something
			}
			_currentCamera = Camera.getCamera( String( index ) );
			if( _currentCamera ) {
				_currentCamera.setMode( 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING, 15, false );
				trace( "camera set, dims: " + _currentCamera.width, _currentCamera.height );
				_video.attachCamera( _currentCamera );
				//TODO: set camera quality?
			}
			_activeCameraIndex = index;
		}

		public function pause():void {

			_bmd = new TrackedBitmapData( _currentCamera.width, _currentCamera.height, false, 0 );
			_currentCamera.drawToBitmapData( _bmd );
			_snapshot.bitmapData = _bmd;
			_snapshot.height = 384;
			_snapshot.width = 512;

			_video.attachCamera( null );

			clearAllTweens();
			cameraLeave();
		}

		public function play():void {
			_video.attachCamera( _currentCamera );
			clearAllTweens();
			cameraEnter( _speed );
		}

		public function takeSnapshot():BitmapData {
			return _bmd;
		}

		public function flipCamera():void {
			if( !CoreSettings.RUNNING_ON_iPAD ) return;
			setCameraByIndex( _activeCameraIndex == 0 ? 1 : 0 );
		}

		// -----------------------
		// Animation.
		// -----------------------

		private function cameraEnter( delay:Number = 0 ):void {

			cameraInitPos();

			TweenLite.to( _video, _speed, { delay: delay, x : _videoPos.x, y : _videoPos.y, ease : Strong.easeOut, onStart:onCameraEnterStart } );
			TweenLite.to( photoCamera, _speed, { delay: delay, x : 0, y : 0, ease : Strong.easeOut} );
		}

		private function cameraLeave( delay:Number = 0 ):void {

			TweenLite.to( _video, _speed, { delay: delay, x : _videoPos.x - _moveToSideBy, y : _videoPos.y + stage.height, ease : Strong.easeIn} );
			TweenLite.to( photoCamera, _speed, { delay: delay, x : -_moveToSideBy, y : stage.height, ease : Strong.easeIn} );
		}

		private function cameraInitPos():void {

			_video.x = _videoPos.x - _moveToSideBy;
			_video.y = _videoPos.y + stage.height;
			photoCamera.x = - _moveToSideBy;
			photoCamera.y = stage.height;
		}

		private function snapshotInitPos():void {
			_snapshot.x = _snapshotPos.x + _moveToSideBy;
			_snapshot.y = _snapshotPos.y + stage.height;
		}

		private function onCameraEnterStart():void{
			_video.visible = true;
			_snapshot.visible = false;
			photoCamera.visible = true;
		}

		private function clearAllTweens():void {
			TweenLite.killTweensOf( _video );
			TweenLite.killTweensOf( _snapshot );
			TweenLite.killTweensOf( photoCamera );
		}
	}
}
