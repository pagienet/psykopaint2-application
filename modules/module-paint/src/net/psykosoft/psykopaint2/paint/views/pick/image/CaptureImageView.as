package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Video;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class CaptureImageView extends ViewBase
	{
		// Declared in Flash.
		public var handHolding:Sprite;
		public var photoCamera:Sprite;

		private var _activeCameraIndex:uint;
		private var _currentCamera:Camera = new Camera();
		private var _video:Video;
		private var _bmd:BitmapData;
		private var _snapshot:Bitmap;

		public function CaptureImageView() {
			super();
		}

		override protected function onEnabled():void {

			_video = new Video( 512, 384 );
			_video.x = 383;
			_video.y = 105;
			_video.smoothing = true;
			addChild( _video );

			_snapshot = new Bitmap();
			_snapshot.visible = false;
			_snapshot.x = 250;
			_snapshot.y = 82;
			_snapshot.scaleX = _snapshot.scaleY = 0.5 / CoreSettings.GLOBAL_SCALING;
			addChild( _snapshot );

			swapChildren( _snapshot, handHolding );
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
				if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) _currentCamera.setMode( 2048, 1536, 15, true );
				else _currentCamera.setMode( 1024, 768, 15, false );
				_video.attachCamera( _currentCamera );
				//TODO: set camera quality?
			}
			_activeCameraIndex = index;
		}

		override protected function onDisabled():void {
			//TODO: check if anything else needs to be disposed.
			_currentCamera = null;
			removeChild( _video );
			_video = null;
			_snapshot.visible = false;
		}

		public function pause():void {

			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) _bmd = new TrackedBitmapData( 2048, 1536, false, 0 );
			else _bmd = new TrackedBitmapData( 1024, 768, false, 0 );
			_currentCamera.drawToBitmapData( _bmd );
			_snapshot.bitmapData = _bmd;
			_video.attachCamera( null );

			_video.visible = false;
			_snapshot.visible = true;

			handHolding.visible = true;
			photoCamera.visible = false;
		}

		public function play():void {

			_video.attachCamera( _currentCamera );

			_video.visible = true;
			_snapshot.visible = false;

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
