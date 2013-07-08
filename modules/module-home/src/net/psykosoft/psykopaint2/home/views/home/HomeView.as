package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.bounds.AxisAlignedBoundingBox;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationCache;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.home.controller.ScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.objects.Painting;
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
		private var _isEnabled3d:Boolean;
		private var _mainScene:ObjectContainer3D;
		private var _freezeScene:ObjectContainer3D;
		private var _freezePlane:Mesh;
		private var _frozen:Boolean;

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

		public function freeze( bmd:BitmapData ):void {
			if( _frozen ) return;
			unFreeze();
			trace( this, "freeze()" );
			if( HomeSettings.TINT_FREEZES ) {
				bmd.colorTransform( bmd.rect, new ColorTransform( 0.75, 0.75, 1, 1 ) );
			}
			_freezePlane = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( bmd, _stage3dProxy );
			_freezePlane.rotationX = -90;
			_freezePlane.z = 10000; // TODO: adjust mathematically, probably will be different on HR too
			ensurePlaneFitsViewport( _freezePlane );
			_freezeScene.addChild( _freezePlane );
			selectScene( _freezeScene );
			disable3d();
			renderScene();
			_frozen = true;
		}

		public function unFreeze():void {
			if( !_frozen ) return;
			trace( this, "unFreeze()" );
			if( _freezePlane ) {
				_freezePlane.dispose();
				var freezePlaneMaterial:TextureMaterial = _freezePlane.material as TextureMaterial;
				if( freezePlaneMaterial ) {
					var freezePlaneTexture:BitmapTexture = freezePlaneMaterial.texture as BitmapTexture;
					if( freezePlaneTexture ) {
						freezePlaneTexture.dispose(); // TODO: review if this is being disposed
					}
					freezePlaneMaterial.dispose(); // TODO: review if this is being disposed
				}
				_freezeScene.removeChild( _freezePlane );
				_freezePlane = null;
			}
			selectScene( _mainScene );
		}

		// TODO: make method to zoom camera to fit a rect

		public function getEaselScreenRect():Rectangle {
			var plane:Mesh = Painting( _paintingManager.easel.painting ).plane;
			var bounds:AxisAlignedBoundingBox = plane.bounds as AxisAlignedBoundingBox;
			var tlCorner:Vector3D = objectSpaceToScreenSpace( plane, new Vector3D( -bounds.halfExtentsX, bounds.halfExtentsZ, 0 ) );
			var brCorner:Vector3D = objectSpaceToScreenSpace( plane, new Vector3D( bounds.halfExtentsX, -bounds.halfExtentsZ, 0 ) );
			return new Rectangle( tlCorner.x, tlCorner.y, brCorner.x - tlCorner.x, brCorner.y - tlCorner.y );
		}

		private function objectSpaceToScreenSpace( plane:Mesh, offset:Vector3D ):Vector3D {

			// Object space.
			var bounds:AxisAlignedBoundingBox = plane.bounds as AxisAlignedBoundingBox;
			var tlCorner:Vector3D = new Vector3D( -bounds.halfExtentsX, bounds.halfExtentsZ, 0 );

			// Scene space.
			tlCorner.scaleBy( plane.scaleX );
			var center:Vector3D = plane.sceneTransform.transformVector( new Vector3D() );
			tlCorner = tlCorner.add( center );
			// Uncomment to visualize 3d point.
			/*var tracer3d:Mesh = new Mesh( new SphereGeometry(), new ColorMaterial( 0x00FF00 ) );
			tracer3d.position = tlCorner;
			_freezeScene.addChild( tracer3d );*/

			// View space.
			var screenPosition:Vector3D = _view.camera.project( tlCorner );
			screenPosition.x = 0.5 * stage.width * ( 1 + screenPosition.x );
			screenPosition.y = 0.5 * stage.height * ( 1 + screenPosition.y );
			// Uncomment to visualize 2d point.
			/*var tracer2d:Sprite = new Sprite();
			tracer2d.graphics.beginFill( 0xFF0000, 0.25 );
			tracer2d.graphics.drawCircle( screenPosition.x, screenPosition.y, 10 );
			tracer2d.graphics.endFill();
			addChild( tracer2d );*/

//			trace( "screen position: " + screenPosition );
			return screenPosition;
		}

		private function ensurePlaneFitsViewport( plane:Mesh ):void {

//			trace( this, "fitting plane to viewport..." );

			// Use a ray to determine the target width of the plane.
			var rayPosition:Vector3D = _view.camera.unproject( 0, 0, 0 );
			var rayDirection:Vector3D = _view.camera.unproject( 1, 0, 1 );
			rayDirection = rayDirection.subtract( rayPosition );
			rayDirection.normalize();
			var t:Number = -( -rayPosition.z + plane.z ) / -rayDirection.z; // Typical ray-plane intersection calculation ( simplified because of zero's ).
			var targetPlaneHalfWidth:Number = rayPosition.x + t * rayDirection.x;
//			trace( "targetPlaneHalfWidth: " + targetPlaneHalfWidth );

			// Scale the plane so that it fits.
			var bounds:AxisAlignedBoundingBox = plane.bounds as AxisAlignedBoundingBox;
//			trace( "actual width: " + bounds.halfExtentsX );
			var sc:Number = targetPlaneHalfWidth / bounds.halfExtentsX;
//			trace( "scale: " + sc );
			plane.scale( sc );
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
			_room = new WallRoom( _view );
			var cameraTarget:Object3D = new Object3D();
			_cameraController.setCamera( _view.camera, cameraTarget );
			_cameraController.stage = stage;
			_paintingManager = new PaintingManager( _cameraController, _room, _view, _lightPicker );
			_paintingManager.y = 400;
			_cameraController.interactionSurfaceZ = _room.wallZ;
			_cameraController.cameraY = cameraTarget.y = HomeSettings.DEFAULT_CAMERA_POSITION.y;
			_cameraController.cameraZ = HomeSettings.DEFAULT_CAMERA_POSITION.z;
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
