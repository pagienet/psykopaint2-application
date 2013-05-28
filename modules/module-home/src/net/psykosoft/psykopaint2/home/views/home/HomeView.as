package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.objects.PictureFrameContainer;
	import net.psykosoft.psykopaint2.home.views.home.objects.Room;

	public class HomeView extends ViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _frameContainer:PictureFrameContainer;
		private var _loader:AssetBundleLoader;
		private var _view:View3D;
		private var _stage3dProxy:Stage3DProxy;

		public function HomeView() {
			super();
		}

		// -----------------------
		// Protected.
		// -----------------------

		override protected function onEnabled():void {
			addChild( _view );
			_cameraController.isActive = true;
		}

		override protected function onDisabled():void {
			// TODO: review if we need to do any clean up when view is disabled
			removeChild( _view );
			_cameraController.isActive = false;
		}

		override protected function onSetup():void {

			// -----------------------
			// Initialize view.
			// -----------------------

			_view = new View3D();
			_view.mouseEnabled = _view.mouseChildren = false;
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.camera.lens.far = 50000;

			// TODO: does the path manager update when scrolling on the 3d view? it shouldn't!

			// -----------------------
			// Initialize objects.
			// -----------------------

			// Visualize scene origin.
//			var tri:Trident = new Trident( 500 );
//			_view.scene.addChild( tri );

			_room = new Room( _view );
			var cameraTarget:Object3D = new Object3D();
			_cameraController = new ScrollCameraController( _view.camera, cameraTarget, stage );
			_frameContainer = new PictureFrameContainer( _cameraController, _room, _view );
			_frameContainer.y = 400;
			_cameraController.interactionSurfaceZ = _room.wallZ;
			_cameraController.cameraZ = -1750;
			_frameContainer.z = _room.wallZ - 2;
			cameraTarget.z = _room.wallZ;
			_view.scene.addChild( _room );
			_view.scene.addChild( _frameContainer );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			_loader = new AssetBundleLoader( "homeView" );
			_loader.addEventListener( Event.COMPLETE, onAssetsReady );

			// Picture frame assets.
			_loader.registerAsset( "/home-packaged/away3d/frames/frames.png", "framesAtlasImage" );
			_loader.registerAsset( "/home-packaged/away3d/frames/frames.xml", "framesAtlasXml" );
			// Default paintings.
			_loader.registerAsset( "/home-packaged/away3d/paintings/home_painting.jpg", "homePainting" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/settings_painting.jpg", "settingsPainting" );
			// Other room stuff.
			_loader.registerAsset( "/home-packaged/away3d/easel/easel.png", "easelImage" );
			// Sample paintings. TODO: should be removed once we have save capabilities
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting0.jpg", "samplePainting0" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting1.jpg", "samplePainting1" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting2.jpg", "samplePainting2" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting3.jpg", "samplePainting3" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting4.jpg", "samplePainting4" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting5.jpg", "samplePainting5" );
			_loader.registerAsset( "/home-packaged/away3d/paintings/sample_painting6.jpg", "samplePainting6" );
			// Room assets.
			_loader.registerAsset( "/home-packaged/away3d/wallpapers/fullsize/default.jpg", "defaultWallpaper" );
			_loader.registerAsset( "/home-packaged/away3d/frames/frame-shadow.png", "frameShadow" );
			_loader.registerAsset( "/home-packaged/away3d/floorpapers/wood.jpg", "floorWood" );

			_loader.startLoad();
		}

		private function onAssetsReady( event:Event ):void {
			_loader.removeEventListener( Event.COMPLETE, onAssetsReady );

			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_frameContainer.loadDefaultHomeFrames();
		}

		override protected function onDisposed():void {

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

			_view.dispose();
			_view = null;

			// TODO: review if memory is really freed up with Scout, it appears not, specially gpu memory
		}

		public function renderScene():void {
//			trace( this, "rendering 3d?" );
			if( !_loader.done ) return; // Bounces off 3d rendering when the scene is not ready or active.
			if( !_view.parent ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering 3d" );
			}
			_cameraController.update();
			_view.render();
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

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
		}
	}
}