package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.view.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.objects.PictureFrameContainer;
	import net.psykosoft.psykopaint2.app.view.home.objects.Room;

	public class HomeView extends Away3dViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _frameManager:PictureFrameContainer;

		public function HomeView() {
			super();
		}

		// -----------------------
		// Protected.
		// -----------------------

		override protected function onEnabled():void {
			addChild3d( _room );
			addChild3d( _frameManager );
		}

		override protected function onDisabled():void {
			removeChild3d( _room );
			removeChild3d( _frameManager );
		}

		override protected function onCreate():void {

			_room = new Room();

			_cameraController = new ScrollCameraController( _camera, _room.wall, stage );

			_frameManager = new PictureFrameContainer( _cameraController, _room );
			_frameManager.y = 400;
			_frameManager.z = _room.wall.z - 2;
			_frameManager.loadDefaultHomeFrames();
		}

		override protected function onDispose():void {

			_cameraController.dispose();
			_cameraController = null;

			_room.dispose();
			_room = null;

			_frameManager.dispose();
			_frameManager = null;

			// TODO: review if memory is really freed up with Scout, it appears not, specially gpu memory
		}

		override protected function onUpdate():void {
			_cameraController.update();
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get frameManager():PictureFrameContainer {
			return _frameManager;
		}

		public function get room():Room {
			return _room;
		}

		public function get cameraController():ScrollCameraController {
			return _cameraController;
		}
	}
}
