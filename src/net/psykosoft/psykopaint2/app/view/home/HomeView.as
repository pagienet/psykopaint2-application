package net.psykosoft.psykopaint2.app.view.home
{

	import flash.events.Event;

	import net.psykosoft.utils.loaders.AssetBundleLoader;
	import net.psykosoft.psykopaint2.app.view.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.objects.PictureFrameContainer;
	import net.psykosoft.psykopaint2.app.view.home.objects.Room;

	public class HomeView extends Away3dViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _frameManager:PictureFrameContainer;
		private var _loader:AssetBundleLoader;

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

			// -----------------------
			// Initialize objects.
			// -----------------------

			_room = new Room();
			_cameraController = new ScrollCameraController( _camera, stage );
			_frameManager = new PictureFrameContainer( _cameraController, _room );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			_loader = new AssetBundleLoader( "homeView" );
			_loader.addEventListener( Event.COMPLETE, onAssetsReady );

			// Picture frame assets.
			_loader.registerAsset( "/assets-packaged/away3d/frames/frames.png", "framesAtlasImage" );
			_loader.registerAsset( "/assets-packaged/away3d/frames/frames.xml", "framesAtlasXml" );
			// Room assets.
			_loader.registerAsset( "/assets-packaged/away3d/frames/frame-shadow.png", "frameShadow" );
			_loader.registerAsset( "/assets-packaged/away3d/floorpapers/wood.jpg", "floorWood" );

			_loader.startLoad();
		}

		private function onAssetsReady( event:Event ):void {
			_loader.removeEventListener( Event.COMPLETE, onAssetsReady );

			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_cameraController.wall = _room.wall;
			_frameManager.loadDefaultHomeFrames();
			_frameManager.y = 400;
			_frameManager.z = _room.wall.z - 2;
		}

		override protected function onDispose():void {

			if( _loader.hasEventListener( Event.COMPLETE ) ) {
				_loader.removeEventListener( Event.COMPLETE, onAssetsReady );
			}
			_loader.dispose();
			_loader = null;

			_cameraController.dispose();
			_cameraController = null;

			_room.dispose();
			_room = null;

			_frameManager.dispose();
			_frameManager = null;

			// TODO: review if memory is really freed up with Scout, it appears not, specially gpu memory
		}

		override protected function onUpdate():void {
			if( !_loader.done ) return;
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
