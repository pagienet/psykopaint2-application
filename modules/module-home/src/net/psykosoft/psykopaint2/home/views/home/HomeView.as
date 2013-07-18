package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.arcane;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.hacks.NativeTexture;
	import away3d.lights.DirectionalLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Stage3dTexture;
	import away3d.textures.Texture2DBase;

	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.home.camera.HScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.camera.ZoomCameraController;
	import net.psykosoft.psykopaint2.home.views.home.objects.FrameType;
	import net.psykosoft.psykopaint2.home.views.home.objects.GalleryPainting;
	import net.psykosoft.psykopaint2.home.views.home.objects.PaintingManager;
	import net.psykosoft.psykopaint2.home.views.home.objects.Room;

	use namespace arcane;

	// TODO: whole view is in need of a serious clean-up

	public class HomeView extends ViewBase
	{
		private var _scrollCameraController:HScrollCameraController;
		private var _zoomCameraController:ZoomCameraController;
		private var _room:Room;
		private var _paintingManager:PaintingManager;
		private var _loader:AssetBundleLoader;
		private var _view:View3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _shiftMultiplier:Number = 1;
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		private var _isCameraControllerEnabled:Boolean;
		private var _mainScene:ObjectContainer3D;


		public static const HOME_BUNDLE_ID:String = "homeView";

		private var _frozen:Boolean;
		private var _freezeTexture:RefCountedTexture;

		private var _currentScene:ObjectContainer3D;

		public function HomeView() {
			super();
			scalesToRetina = false;
			_scrollCameraController = new HScrollCameraController();
			_zoomCameraController = new ZoomCameraController();
			initializeBundledAssets( HOME_BUNDLE_ID );
		}

		public function freeze( texture:RefCountedTexture ):void {

			if( _frozen ) return;
			unFreeze();
			trace( this, "freeze()" );

			disposeFreezeTexture();

			_freezeTexture = texture;
			var tex:NativeTexture = new NativeTexture(_freezeTexture.texture);
			_view.background = tex;
			var texHeight : Number = TextureUtil.getNextPowerOfTwo(stage.height);
			_view.backgroundRect = new Rectangle(0, 0, 1, stage.height/texHeight);

			selectScene( null );
			disableCameraController();

			_frozen = true;
		}

		public function unFreeze():void {

			if( !_frozen ) return;
			trace( this, "unFreeze()" );

			_view.background = null;

			disposeFreezeTexture();

			selectScene( _mainScene );
			enableCameraController();
			_frozen = false;
		}

		private function disposeFreezeTexture():void {
			if( _freezeTexture ) {
				_freezeTexture.dispose();
				_freezeTexture = null;
			}
		}

		// ---------------------------------------------------------------------
		// Creation...
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {
			addChild( _view );
			enableCameraController();
		}

		override protected function onDisabled():void {
			// TODO: review if we need to do any clean up when view is disabled
			removeChild( _view );
			disableCameraController();
			_frozen = false;
		}

		private function enableCameraController():void {
			_scrollCameraController.isEnabled = true;
			_isCameraControllerEnabled = true;
		}

		private function disableCameraController():void {
			_scrollCameraController.isEnabled = false;
			_isCameraControllerEnabled = false;
		}

		private function selectScene( scene:ObjectContainer3D ):void {
			if( _currentScene && _view.scene.contains( _currentScene ) )
				_view.scene.removeChild( _currentScene );
			if( scene ) {
				_view.scene.addChild( scene );
				_currentScene = scene;
			}
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
			PerspectiveLens( _view.camera.lens ).fieldOfView = 70;

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
			selectScene( _mainScene );

			// -----------------------
			// Initialize objects.
			// -----------------------

			// Visualize scene origin.
//			var tri:Trident = new Trident( 500 );
//			_view.scene.addChild( tri );

			_light = new DirectionalLight( -1, -1, 2 );
			_light.ambient = 1;
			_light.color = 0x989589;
			_light.ambientColor = 0x808088;
			_lightPicker = new StaticLightPicker( [_light] );
			_room = new Room( _view, _stage3dProxy );

			var cameraTarget:Object3D = new Object3D();
			_scrollCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.yzChangedSignal.add( onZoomControllerChange );
			_scrollCameraController.stage = stage;
			_view.camera.z = HomeSettings.DEFAULT_CAMERA_Z;

			_paintingManager = new PaintingManager( _scrollCameraController, _room, _view, _lightPicker, _stage3dProxy );
			_paintingManager.y = 850;
			_scrollCameraController.interactionSurfaceZ = _room.wallZ;
			_paintingManager.z = _room.wallZ - 2;
			cameraTarget.z = _room.wallZ;
			_mainScene.addChild( _scrollCameraController );
			_mainScene.addChild( _room );
			_mainScene.addChild( _paintingManager );
			_mainScene.addChild( _light );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";

			// Default paintings.
			registerBundledAsset( "/home-packaged/away3d/frames/whiteFrame.png", FrameType.WHITE_FRAME );
			registerBundledAsset( "/home-packaged/away3d/paintings/settingsFrame.png", "settingsPainting" );
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

		private function onZoomControllerChange():void {
			_scrollCameraController.dirtyZ();
		}

		override protected function onAssetsReady():void {
			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_paintingManager.createDefaultPaintings();

			// Start docked at home painting and zoom out.
			_scrollCameraController.jumpToSnapPointIndex( _paintingManager.homePaintingIndex );
			dockAtCurrentPainting();
			_zoomCameraController.animateToYZ( HomeSettings.DEFAULT_CAMERA_Y, HomeSettings.DEFAULT_CAMERA_Z, 1, 3 );
		}

		private function dockAtCurrentPainting():void {
			var framedPainting:GalleryPainting = _paintingManager.getPaintingAtIndex( _scrollCameraController.positionManager.closestSnapPointIndex );
			var plane:Mesh = framedPainting.painting;
			var pos:Vector3D = HomeViewUtils.calculateCameraYZToFitPlaneOnViewport( plane, _view, 768 / 1024 );
			_zoomCameraController.setYZ( pos.y, pos.z );
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

			disposeFreezeTexture();

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

			if( _scrollCameraController ) {
				_scrollCameraController.dispose();
				_scrollCameraController = null;
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

		public function get scrollCameraController():HScrollCameraController {
			return _scrollCameraController;
		}

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
			setup();
		}

		public function getCurrentPaintingIndex():uint {
			return _scrollCameraController.positionManager.closestSnapPointIndex;
		}

		public function renderScene( target:Texture ):void {
//			trace( this, "rendering 3d?" );
			if( !_isEnabled ) return;
			if( !_assetsLoaded ) return; // Bounces off 3d rendering when the scene is not ready or active.
			if( !_view.parent ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering 3d" );
			}
			_scrollCameraController.update();
			_view.render( target );
		}

		public function get zoomCameraController():ZoomCameraController {
			return _zoomCameraController;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onStageKeyUp( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SHIFT:
				{
					_shiftMultiplier = 1;
					break;
				}
			}
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.UP:
				{
//					_room.settingsPanel.y += _shiftMultiplier;
					_zoomCameraController.setYZ( _view.camera.y + _shiftMultiplier, _view.camera.z );
					break;
				}
				case Keyboard.DOWN:
				{
//					_room.settingsPanel.y -= _shiftMultiplier;
					_zoomCameraController.setYZ( _view.camera.y - _shiftMultiplier, _view.camera.z );
					break;
				}
				case Keyboard.RIGHT:
				{
//					_room.settingsPanel.x += _shiftMultiplier;
//					_room.wall.x += _shiftMultiplier;
					_zoomCameraController.setYZ( _view.camera.y, _view.camera.z + _shiftMultiplier );
					break;
				}
				case Keyboard.LEFT:
				{
//					_room.settingsPanel.x -= _shiftMultiplier;
//					_room.wall.x -= _shiftMultiplier;
					_zoomCameraController.setYZ( _view.camera.y, _view.camera.z - _shiftMultiplier );
					break;
				}
				case Keyboard.SHIFT:
				{
					_shiftMultiplier = 10;
					break;
				}
			}

//			trace( this, "positioning settings panel - x: " + _room.settingsPanel.x + ", y: " + _room.settingsPanel.y );
//			trace( this, "positioning wall - x: " + _room.wall.x );
			trace( this, "positioning camera, Y: " + _view.camera.y + ", Z: " + _view.camera.z );
		}

		public function setEaselContent( data:PaintingInfoVO ):void {
			_paintingManager.setEaselContent( data );
		}

		public function get frozen():Boolean {
			return _frozen;
		}

		public function get easelRect():Rectangle {
			var plane:Mesh = _paintingManager.easel.painting;
			var rect:Rectangle = HomeViewUtils.calculatePlaneScreenRect( plane, _view, 1 );
			// Uncomment to debug rect on screen.
			/*this.graphics.lineStyle( 1, 0xFF0000 );
			this.graphics.drawRect( rect.x * CoreSettings.GLOBAL_SCALING, rect.y * CoreSettings.GLOBAL_SCALING,
					rect.width * CoreSettings.GLOBAL_SCALING, rect.height * CoreSettings.GLOBAL_SCALING );
			this.graphics.endFill();*/
			return rect;
		}
	}
}
