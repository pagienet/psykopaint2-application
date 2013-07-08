package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.lightpickers.StaticLightPicker;

	import flash.display.Bitmap;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationCache;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.objects.PaintingManager;
	import net.psykosoft.psykopaint2.home.views.home.objects.WallRoom;

	public class HomeView extends ViewBase
	{
		private var _cameraController:ScrollCameraController;
		private var _room:WallRoom;
		private var _paintingManager:PaintingManager;
		private var _loader:AssetBundleLoader;
		private var _view:View3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _introZoomOutPending:Boolean = true;
		private var _shiftMultiplier:Number = 1;
		private var _light : DirectionalLight;
		private var _lightPicker : StaticLightPicker;

		public static const HOME_BUNDLE_ID:String = "homeView";
		public static const DEFAULT_ZOOM_IN:Point = new Point( 400, -800 );
		public static const EASEL_CLOSE_ZOOM_IN:Point = new Point( 315, -900 );
		public static const EASEL_FAR_ZOOM_IN:Point = new Point( 170, -1160 );


		public function HomeView() {
			super();
			scalesToRetina = false;
			_cameraController = new ScrollCameraController();
			initializeBundledAssets( HOME_BUNDLE_ID );
		}

		private var _freezeBitmap:Bitmap;
		private var _frozen:Boolean;

		public function freeze( bmd:BitmapData ):void {
			if( _frozen ) return;
			unFreeze();
			_freezeBitmap = new Bitmap();
			_freezeBitmap.transform.colorTransform = new ColorTransform( -1, -1, -1 );
			_freezeBitmap.bitmapData = bmd;
			addChild( _freezeBitmap );
			disable();
			_frozen = true;
		}

		private function unFreeze():void {
			if( _freezeBitmap ) {
				_freezeBitmap.bitmapData.dispose();
				removeChild( _freezeBitmap );
				_freezeBitmap = null;
			}
		}

		// ---------------------------------------------------------------------
		// Creation...
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {
			addChild( _view );
			_cameraController.isEnabled = true;
		}

		override protected function onDisabled():void {
			// TODO: review if we need to do any clean up when view is disabled
			removeChild( _view );
			_cameraController.isEnabled = false;
			_frozen = false;
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
			_room = new WallRoom( _view );
			var cameraTarget:Object3D = new Object3D();
			_cameraController.setCamera( _view.camera, cameraTarget );
			_cameraController.stage = stage;
			_paintingManager = new PaintingManager( _cameraController, _room, _view, _lightPicker );
			_paintingManager.y = 400;
			_cameraController.interactionSurfaceZ = _room.wallZ;
			_cameraController.cameraY = cameraTarget.y = 400;
			_cameraController.cameraZ = -800;
			_paintingManager.z = _room.wallZ - 2;
			cameraTarget.z = _room.wallZ;
			_view.scene.addChild( _cameraController );
			_view.scene.addChild( _room );
			_view.scene.addChild( _paintingManager );
			_view.scene.addChild( _light );

			// -------------------------
			// Prepare external assets.
			// -------------------------

			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";

			// Picture frame assets.
			registerBundledAsset( rootUrl + "away3d/frames/frames" + extra + ".atf", "framesAtlasImage", true );
			registerBundledAsset( "/home-packaged/away3d/frames/frames.xml", "framesAtlasXml" );
			// Default paintings.
			registerBundledAsset( "/home-packaged/away3d/paintings/home_painting.jpg", "homePainting" );
			registerBundledAsset( "/home-packaged/away3d/paintings/settings_painting.jpg", "settingsPainting" );
			// Other room stuff.
			registerBundledAsset( "/home-packaged/away3d/easel/easel-uncompressed.atf", "easelImage", true );
			// Sample paintings. TODO: should be removed once we have save capabilities
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting0.jpg", "samplePainting0" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting1.jpg", "samplePainting1" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting2.jpg", "samplePainting2" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting3.jpg", "samplePainting3" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting4.jpg", "samplePainting4" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting5.jpg", "samplePainting5" );
			registerBundledAsset( "/home-packaged/away3d/paintings/sample_painting6.jpg", "samplePainting6" );
			// Room assets.
			registerBundledAsset( rootUrl + "away3d/wallpapers/fullsize/default" + extra + ".atf", "defaultWallpaper", true );
			registerBundledAsset( "/home-packaged/away3d/frames/frame-shadow-uncompressed.atf", "frameShadow", true );
			registerBundledAsset( rootUrl + "away3d/floorpapers/wood" + extra + "-mips.atf", "floorWood", true );
		}

		override protected function onAssetsReady():void {
			// Stuff that needs to be done after external assets are ready.
			_room.initialize();
			_paintingManager.createDefaultPaintings();
			_cameraController.jumpToSnapPointIndex( _paintingManager.homePaintingIndex );
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

		public function get room():WallRoom {
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

		public function updateEasel( bmd:BitmapData ):void {
//			_paintingManager.updateEasel( bmd );
		}

		public function renderScene():void {
//			trace( this, "rendering 3d?" );
			if( !_assetsLoaded ) return; // Bounces off 3d rendering when the scene is not ready or active.
			if( !_view.parent ) return;
			if( _introZoomOutPending && stage.frameRate > 30 ) {
				_introZoomOutPending = false;
				setTimeout( function():void {
					trace( this, "zooming out 1st..." );
					zoomOut();
				}, 1500 );
			}
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering 3d" );
			}
			_cameraController.update();
			_view.render();
		}

		public function zoomIn():void {
			// TODO: evaluate zoom in y and z for current snap point

			var zoomY:Number = DEFAULT_ZOOM_IN.x;
			var zoomZ:Number = DEFAULT_ZOOM_IN.y;

			var index:uint = _cameraController.positionManager.closestSnapPointIndex;

			// Easel.
			if( index == 1 ) {
				if( !NavigationCache.isHidden ) {
					zoomY = EASEL_FAR_ZOOM_IN.x;
					zoomZ = EASEL_FAR_ZOOM_IN.y;
				}
				else {
					zoomY = EASEL_CLOSE_ZOOM_IN.x;
					zoomZ = EASEL_CLOSE_ZOOM_IN.y;
				}
			}

			trace( this, "zooming in to Y: " + zoomY + ", Z: " + zoomZ );

			_cameraController.zoomIn( zoomY, zoomZ );
		}

		public function adjustCamera( py:Number, pz:Number ):void {
			_cameraController.adjustY( py );
			_cameraController.adjustZ( pz );
		}

		public function zoomOut():void {
			_cameraController.zoomOut();
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
					_cameraController.offsetY( _shiftMultiplier );
					break;
				}
				case Keyboard.DOWN: {
					_cameraController.offsetY( -_shiftMultiplier );
					break;
				}
				case Keyboard.RIGHT: {
					_cameraController.offsetZ( _shiftMultiplier );
					break;
				}
				case Keyboard.LEFT: {
					_cameraController.offsetZ( -_shiftMultiplier );
					break;
				}
				case Keyboard.SHIFT: {
					_shiftMultiplier = 10;
					break;
				}
			}
			trace( this, "positioning camera, Y: " + _cameraController.camera.y + ", Z: " + _cameraController.camera.z );
		}
	}
}
