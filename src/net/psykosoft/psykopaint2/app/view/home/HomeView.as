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
		private var _frameContainer:PictureFrameContainer;
		private var _loader:AssetBundleLoader;

		public function HomeView() {
			super();
		}

		// -----------------------
		// Protected.
		// -----------------------

		override protected function onEnabled():void {
			addChild3d( _room );
			addChild3d( _frameContainer );
		}

		override protected function onDisabled():void {
			removeChild3d( _room );
			removeChild3d( _frameContainer );
		}

		override protected function onCreate():void {

			// -----------------------
			// Initialize objects.
			// -----------------------

			_room = new Room();
			_cameraController = new ScrollCameraController( _camera, stage );
			_frameContainer = new PictureFrameContainer( _cameraController, _room );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			_loader = new AssetBundleLoader( "homeView" );
			_loader.addEventListener( Event.COMPLETE, onAssetsReady );

			// Picture frame assets.
			_loader.registerAsset( "/assets-packaged/away3d/frames/frames.png", "framesAtlasImage" );
			_loader.registerAsset( "/assets-packaged/away3d/frames/frames.xml", "framesAtlasXml" );
			// Default paintings.
			_loader.registerAsset( "/assets-packaged/away3d/paintings/home_painting.jpg", "homePainting" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/settings_painting.jpg", "settingsPainting" );
			// Sample paintings. TODO: should be removed once we have save capabilities
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting0.jpg", "samplePainting0" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting1.jpg", "samplePainting1" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting2.jpg", "samplePainting2" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting3.jpg", "samplePainting3" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting4.jpg", "samplePainting4" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting5.jpg", "samplePainting5" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting6.jpg", "samplePainting6" );
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
			_frameContainer.loadDefaultHomeFrames();
			_frameContainer.y = 400;
			_frameContainer.z = _room.wall.z - 2;
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

			_frameContainer.dispose();
			_frameContainer = null;

			// TODO: review if memory is really freed up with Scout, it appears not, specially gpu memory
		}

		override protected function onUpdate():void {
			if( !_loader.done ) return;
			_cameraController.update();
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get frameContainer():PictureFrameContainer {
			return _frameContainer;
		}

		public function get room():Room {
			return _room;
		}

		public function get cameraController():ScrollCameraController {
			return _cameraController;
		}
	}
}
