package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.objects.FramedPainting;
	import net.psykosoft.psykopaint2.home.views.home.objects.GalleryPainting;
	import net.psykosoft.psykopaint2.home.views.home.objects.PaintingManager;
	import net.psykosoft.psykopaint2.home.views.home.objects.Room;

	use namespace arcane;

	// TODO: whole view is in need of a serious clean-up

	public class HomeView extends ViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:Room;
		private var _paintingManager:PaintingManager;
		private var _loader:AssetBundleLoader;
		private var _view:View3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _shiftMultiplier:Number = 1;
		private var _light : DirectionalLight;
		private var _lightPicker : StaticLightPicker;
		private var _isEnabled3d:Boolean;
		private var _mainScene:ObjectContainer3D;
		private var _freezeScene:ObjectContainer3D;
		private var _freezePlane:Mesh;
		private var _frozen:Boolean;
		private var _freezeCameraTransformCache:Matrix3D;

		public static const HOME_BUNDLE_ID:String = "homeView";

		public function HomeView() {
			super();
			scalesToRetina = false;
			_cameraController = new ScrollCameraController();
			initializeBundledAssets( HOME_BUNDLE_ID );
		}

		public function showEasel( show:Boolean ):void {
			_paintingManager.easel.visible = show;
		}

		public function freeze( bmd:BitmapData ):void {
			if( _frozen ) return;
			unFreeze();
			trace( this, "freeze()" );
			if( HomeSettings.TINT_FREEZES ) {
				bmd.colorTransform( bmd.rect, new ColorTransform( 0.75, 0.75, 1, 1 ) );
			}
			selectScene( _freezeScene );
			disable3d();
			renderScene(); // TODO: needed?
			_freezePlane = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( bmd, _stage3dProxy );
			_freezePlane.rotationX = -90;
			_freezeCameraTransformCache = _view.camera.transform.clone();
			_view.camera.transform = new Matrix3D();
			_freezePlane.z = 10000;
			_freezeScene.addChild( _freezePlane );
			HomeViewUtils.ensurePlaneFitsViewport( _freezePlane, _view );
			_frozen = true;
		}

		public function unFreeze():void {
			if( !_frozen ) return;
			trace( this, "unFreeze()" );
			if( _freezePlane ) {
				if( _freezeScene.contains( _freezePlane ) ) {
					_freezeScene.removeChild( _freezePlane );
				}

				var freezePlaneMaterial:TextureMaterial = _freezePlane.material as TextureMaterial;
				if( freezePlaneMaterial ) {
					var freezePlaneTexture:BitmapTexture = freezePlaneMaterial.texture as BitmapTexture;
					if( freezePlaneTexture ) {
						freezePlaneTexture.dispose(); // TODO: review if this is being disposed
					}
					freezePlaneMaterial.dispose(); // TODO: review if this is being disposed
				}
				_freezePlane.dispose();
				_freezePlane = null;
			}
			_view.camera.transform = _freezeCameraTransformCache;
			selectScene( _mainScene );
			enable3d();
			_frozen = false;
		}

		// ---------------------------------------------------------------------
		// Creation...
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {
			addChild( _view );
			enable3d();
		}

		override protected function onDisabled():void {
			// TODO: review if we need to do any clean up when view is disabled
			removeChild( _view );
			disable3d();
			_frozen = false;
		}

		private function enable3d():void {
			if( _isEnabled3d ) return;
			_cameraController.isEnabled = true;
			_isEnabled3d = true;
		}

		private function disable3d():void {
			if( !_isEnabled3d ) return;
			_cameraController.isEnabled = false;
			_isEnabled3d = false;
		}

		private function selectScene( scene:ObjectContainer3D ):void {
			var otherScene:ObjectContainer3D = scene == _mainScene ? _freezeScene : _mainScene;
			if( _view.scene.contains( otherScene ) ) _view.scene.removeChild( otherScene );
			_view.scene.addChild( scene );
		}

		override protected function onSetup():void {

			// -----------------------
			// Initialize view.
			// -----------------------

			// TODO: make distinctions between first set up and potentially later ones because of memory warning cleanups.

			_view = new View3D();
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_view.camera.lens.far = 50000;

			// TODO: does the path manager update when scrolling on the 3d view? it shouldn't!

			// -----------------------
			// Key debugging.
			// -----------------------

			// TODO: remove on release
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onStageKeyUp );

			// -----------------------
			// Scenes.
			// -----------------------

			_mainScene = new ObjectContainer3D();

			_freezeScene = new ObjectContainer3D();

			selectScene( _mainScene );

			// -----------------------
			// Initialize objects.
			// -----------------------

			// Visualize scene origin.
//			var tri:Trident = new Trident( 500 );
//			_view.scene.addChild( tri );

			_light = new DirectionalLight(-1, -1, 2);
			_light.ambient = 1;
			_light.color = 0x989589;
			_light.ambientColor = 0x808088;
			_lightPicker = new StaticLightPicker([_light]);
			_room = new Room( _view, _stage3dProxy );
			var cameraTarget:Object3D = new Object3D();
			_cameraController.setCamera( _view.camera, cameraTarget );
			_cameraController.stage = stage;
			_paintingManager = new PaintingManager( _cameraController, _room, _view, _lightPicker, _stage3dProxy );
			_paintingManager.y = 400;
			_cameraController.interactionSurfaceZ = _room.wallZ;
			_paintingManager.z = _room.wallZ - 2;
			cameraTarget.z = _room.wallZ;
			_mainScene.addChild( _cameraController );
			_mainScene.addChild( _room );
			_mainScene.addChild( _paintingManager );
			_mainScene.addChild( _light );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";

			// Default paintings.
			registerBundledAsset( "/home-packaged/away3d/paintings/HomeScreen.png", "homePainting" );
			registerBundledAsset( "/home-packaged/away3d/paintings/settings.png", "settingsPainting" );
			// Other room stuff.
			registerBundledAsset( "/home-packaged/away3d/easel/easel-uncompressed.atf", "easelImage", true );
			registerBundledAsset( "/home-packaged/away3d/objects/settingsPanel.png", "settingsPanel" );
			// Sample paintings. TODO: should be removed once we have save capabilities
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting0.jpg", "samplePainting0" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting1.jpg", "samplePainting1" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting2.jpg", "samplePainting2" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting3.jpg", "samplePainting3" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting4.jpg", "samplePainting4" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting5.jpg", "samplePainting5" );
//			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting6.jpg", "samplePainting6" );
			// Room assets.
			registerBundledAsset( rootUrl + "away3d/wallpapers/fullsize/white" + extra + ".atf", "defaultWallpaper", true );
			registerBundledAsset( rootUrl + "away3d/floorpapers/wood" + extra + "-mips.atf", "floorWood", true );
		}

		override protected function onAssetsReady():void {
			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_paintingManager.createDefaultPaintings();

			// Start docked at home painting.
			_cameraController.jumpToSnapPointIndex( _paintingManager.homePaintingIndex );
//			dockAtCurrentPainting(); // TODO: dock at painting and zoom out
		}

		private function dockAtCurrentPainting():void {
			trace( this, "docking at current painting ----------" );
			var framedPainting:GalleryPainting = _paintingManager.getPaintingAtIndex( _cameraController.positionManager.closestSnapPointIndex );
			var plane:Mesh = framedPainting.painting;
			var pos:Vector3D = HomeViewUtils.calculateCameraYZToFitPlaneOnViewport( plane, _view, 768 / 1024 );
			_cameraController.dock( pos.y, pos.z );
		}

		override protected function onDisposed():void {

			// TODO: can't clean up everything because it causes runtime errors, use scout to see if the memory is being freed up
			/*
			* For the time being I'm disposing meshes only, but we have to dispose materials too...
			* UPDATE AWAY3D FIRST
			*
			* Getting an error in the drawing core now. Away3D disposal fucks up something in the GPU.
			* */
			_setupHasRan = true;
 			return;

			if( _loader ) {
				if( _loader.hasEventListener( Event.COMPLETE ) ) {
					_loader.removeEventListener( Event.COMPLETE, onAssetsReady );
				}
				_loader.dispose();
				_loader = null;
			}

			if( _room ) {
				_room.dispose();
				_room = null;
			}

			if( _paintingManager ) {
				_paintingManager.dispose();
				_paintingManager = null;
			}

			if( _cameraController ) {
				_cameraController.dispose();
				_cameraController = null;
			}

			if( _view ) {
				_view.dispose();
				_view = null;
			}

			// TODO: review if memory is really freed up with Scout, it appears not, specially gpu memory
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function get paintingManager():PaintingManager {
			return _paintingManager;
		}

		public function get room():Room {
			return _room;
		}

		public function get cameraController():ScrollCameraController {
			return _cameraController;
		}

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
			setup();
		}

		public function getCurrentPaintingIndex():uint {
			return _cameraController.positionManager.closestSnapPointIndex;
		}

		public function renderScene():void {
//			trace( this, "rendering 3d?" );
			if( !_isEnabled ) return;
			if( !_assetsLoaded ) return; // Bounces off 3d rendering when the scene is not ready or active.
			if( !_view.parent ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering 3d" );
			}
			_cameraController.update();
			_view.render();
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onStageKeyUp( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SHIFT: {
					_shiftMultiplier = 1;
					break;
				}
			}
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.UP: {
//					_room.settingsPanel.y += _shiftMultiplier;
//					_cameraController.offsetY( _shiftMultiplier );
					break;
				}
				case Keyboard.DOWN: {
//					_room.settingsPanel.y -= _shiftMultiplier;
//					_cameraController.offsetY( -_shiftMultiplier );
					break;
				}
				case Keyboard.RIGHT: {
//					_room.settingsPanel.x += _shiftMultiplier;
//					_room.wall.x += _shiftMultiplier;
//					_cameraController.offsetZ( _shiftMultiplier );
					break;
				}
				case Keyboard.LEFT: {
//					_room.settingsPanel.x -= _shiftMultiplier;
//					_room.wall.x -= _shiftMultiplier;
//					_cameraController.offsetZ( -_shiftMultiplier );
					break;
				}
				case Keyboard.SHIFT: {
					_shiftMultiplier = 10;
					break;
				}
			}

//			trace( this, "positioning settings panel - x: " + _room.settingsPanel.x + ", y: " + _room.settingsPanel.y );
//			trace( this, "positioning wall - x: " + _room.wall.x );
//			trace( this, "positioning camera, Y: " + _cameraController.camera.y + ", Z: " + _cameraController.camera.z );
		}

		public function setEaselContent( data:PaintingInfoVO ):void {
			_paintingManager.setEaselContent( data );
		}

		public function get easelRect():Rectangle {
			if( _frozen ) _view.camera.transform = _freezeCameraTransformCache;
			var rect:Rectangle = HomeViewUtils.calculatePlaneScreenRect( _paintingManager.easel.painting, _view, 1 );
			if( _frozen ) _view.camera.transform = new Matrix3D();
			return rect;
		}

		public function get frozen():Boolean {
			return _frozen;
		}
	}
}
