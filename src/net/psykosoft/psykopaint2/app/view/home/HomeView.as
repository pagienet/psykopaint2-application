package net.psykosoft.psykopaint2.app.view.home
{

	import away3d.core.base.Object3D;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.app.view.base.Away3dViewBase;
	import net.psykosoft.psykopaint2.app.view.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.app.view.home.objects.PictureFrameContainer;
	import net.psykosoft.psykopaint2.app.view.home.objects.Room;
	import net.psykosoft.utils.loaders.AssetBundleLoader;

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
			_cameraController.isActive = true;
		}

		override protected function onDisabled():void {
			removeChild3d( _room );
			removeChild3d( _frameContainer );
			_cameraController.isActive = false;
		}

		override protected function onCreate():void {

			// -----------------------
			// Initialize objects.
			// -----------------------

			// Visualize scene origin.
//			var tri:Trident = new Trident( 500 );
//			addChild3d( tri );

			_room = new Room();
			var cameraTarget:Object3D = new Object3D();
			_cameraController = new ScrollCameraController( _camera, cameraTarget, stage );
			_frameContainer = new PictureFrameContainer( _cameraController, _room );
			_frameContainer.y = 400;
			_cameraController.interactionSurfaceZ = _room.wallZ;
			_cameraController.cameraZ = -1750;
			_frameContainer.z = _room.wallZ - 2;
			cameraTarget.z = _room.wallZ;

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
			// Other room stuff.
			_loader.registerAsset( "/assets-packaged/away3d/easel/easel.png", "easelImage" );
			// Sample paintings. TODO: should be removed once we have save capabilities
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting0.jpg", "samplePainting0" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting1.jpg", "samplePainting1" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting2.jpg", "samplePainting2" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting3.jpg", "samplePainting3" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting4.jpg", "samplePainting4" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting5.jpg", "samplePainting5" );
			_loader.registerAsset( "/assets-packaged/away3d/paintings/sample_painting6.jpg", "samplePainting6" );
			// Room assets.
			_loader.registerAsset( "/assets-packaged/away3d/wallpapers/fullsize/default.jpg", "defaultWallpaper" );
			_loader.registerAsset( "/assets-packaged/away3d/frames/frame-shadow.png", "frameShadow" );
			_loader.registerAsset( "/assets-packaged/away3d/floorpapers/wood.jpg", "floorWood" );

			_loader.startLoad();
		}

		private function onAssetsReady( event:Event ):void {
			_loader.removeEventListener( Event.COMPLETE, onAssetsReady );

			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_frameContainer.loadDefaultHomeFrames();

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
//			trace( this, "update" );
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
