package net.psykosoft.psykopaint2.app.view.popups
{

	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.app.utils.StarlingCamera;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpViewBase;

	public class CaptureImagePopUpView extends PopUpViewBase
	{
		private var _camera:StarlingCamera;
		private var _currentCamera:uint = 0;

		public function CaptureImagePopUpView() {
			super();
			_useBlocker = false;
		}

		override protected function finishedAnimating():void {

			_camera = new StarlingCamera();
			_camera.x = stage.stageWidth / 2 - 512 / 2;
			_camera.y = stage.stageHeight / 2 - 512 / 2;

			var cameraViewPort:Rectangle = new Rectangle( 0, 0, 512, 512 );
			var cameraFps:uint = 8;
			var cameraDownSample:Number = 1;
			_camera.init( cameraViewPort, cameraFps, cameraDownSample, false );
			_camera.selectCamera( _currentCamera );
			addChild( _camera );
		}

		public function flipCamera():void {
			_currentCamera = _currentCamera == 0 ? 1 : 0;
			_camera.selectCamera( _currentCamera );
		}

		// TODO: destroy camera on pop up removal?
	}
}
