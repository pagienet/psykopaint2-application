package net.psykosoft.psykopaint2.app.view.home
{

	import net.psykosoft.psykopaint2.app.view.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.objects.FrameManager;
	import net.psykosoft.psykopaint2.app.view.home.objects.Room;

	public class HomeView extends Away3dViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _frameManager:FrameManager;

		public function HomeView() {
			super();
		}

		// -----------------------
		// Protected.
		// -----------------------

		override protected function onEnabled():void {

			// TODO: decide what to do when the view is enabled, create everything again, or cache something?

			if( !_room ) {
				_room = new Room();
				addChild3d( _room );
			}

			if( !_cameraController ) {
				_cameraController = new ScrollCameraController( _camera, _room.wall, stage );
			}

			if( !_frameManager ) {
				_frameManager = new FrameManager( _cameraController, _room );
				_frameManager.y = 400;
				_frameManager.z = _room.wall.z - 2;
				_frameManager.loadDefaultHomeFrames();
				_frameManager.loadUserFrames();
				addChild3d( _frameManager );
			}
		}

		override protected function onDisabled():void {

			// TODO: decide what is to be done when the view is deactivated...

			// TODO: Remove frames from frame holder.
			/*var len:uint = _wallFrames.length;
			for( var i:uint = 0; i < len; ++i ) {
				var wallFrame:PictureFrame = _wallFrames[ i ];
				removeChild3d( wallFrame );
				// TODO: add destroy method to wallFrame?
			}*/

			// TODO: Remove frame shadows from room.
			/*for each( var mesh:Mesh in _shadows ) {
				removeChild3d( mesh );
				mesh.dispose();
				mesh = null;
			}*/

			// TODO: reset or destroy camera controller?
//			_cameraController.reset();
		}

		override protected function onUpdate():void {
			_cameraController.update();
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get frameManager():FrameManager {
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
