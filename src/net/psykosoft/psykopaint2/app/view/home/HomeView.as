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

			// TODO: Review construction/deconstruction.
			/*
			* The current approach is to build and destroy everything each time the view is shown/hidden.
			* Scout does not show significant memory and gpu memory releases unless the textures used in this view are released manually,
			* which does show good memory releasing, but causes an error when an attempt to use the externally managed textures ( ManagedAway3DBitmapTexture ) is made.
			* */

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

			trace( this, "onDisabled()" );

			_cameraController.dispose();
			_cameraController = null;

			_room.dispose();
			_room = null;

			_frameManager.dispose();
			_frameManager = null;
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
