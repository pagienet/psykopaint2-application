package net.psykosoft.psykopaint2.home.views.home
{

	import away3d.arcane;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.Object3DEvent;
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

	import org.osflash.signals.Signal;

	use namespace arcane;

	// TODO: whole view is in need of a serious clean-up

	public class HomeView extends ViewBase
	{
		private var _scrollCameraController:HScrollCameraController;
		private var _zoomCameraController:ZoomCameraController;
		private var _room:Room;
		private var _paintingManager:PaintingManager;
		private var _view:View3D;
		private var _stage3dProxy:Stage3DProxy;
		private var _shiftMultiplier:Number = 1;
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		private var _mainScene:ObjectContainer3D;

		public static const HOME_BUNDLE_ID:String = "HomeBundle";

		private var _currentScene:ObjectContainer3D;

		public var closestPaintingChangedSignal:Signal;
		public var zoomCompletedSignal:Signal;
		public var easelRectChanged:Signal;

		public function HomeView() {
			super();
			scalesToRetina = false;
			closestPaintingChangedSignal = new Signal();
			zoomCompletedSignal = new Signal();
			easelRectChanged = new Signal();
		}

		public function buildScene( stage3dProxy:Stage3DProxy ):void {

			_stage3dProxy = stage3dProxy;

			// -----------------------
			// Initialize view.
			// -----------------------

			_view = new View3D();
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_view.camera.lens.far = 50000;
			addChild( _view );
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

			_light = new DirectionalLight( -1, -1, 2 );
			_light.ambient = 1;
			_light.color = 0x989589;
			_light.ambientColor = 0x808088;
			_lightPicker = new StaticLightPicker( [_light] );
			_room = new Room( _view, _stage3dProxy );

			var cameraTarget:Object3D = new Object3D();
			_scrollCameraController = new HScrollCameraController();
			_zoomCameraController = new ZoomCameraController();
			_scrollCameraController.closestSnapPointChangedSignal.add( onClosestPaintingChanged );
			_zoomCameraController.zoomCompleteSignal.add( onZoomComplete );
			_scrollCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.setYZ( HomeSettings.DEFAULT_CAMERA_Y, HomeSettings.DEFAULT_CAMERA_Z );
			_zoomCameraController.yzChangedSignal.add( onZoomControllerChange );
			_view.camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraSceneTransformChanged);
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

			_room.initialize();
			_paintingManager.createDefaultPaintings();

			// Always start at easel.
			_scrollCameraController.jumpToSnapPointIndex( 1 );

			// TODO: needed?
			_stage3dProxy.clear();
			_view.render();
		}

		private function onCameraSceneTransformChanged(event : Object3DEvent) : void
		{
			easelRectChanged.dispatch();
		}

		public function destroyScene():void {

			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
			stage.removeEventListener( KeyboardEvent.KEY_UP, onStageKeyUp );

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
				removeChild( _view );
				_view.dispose();
				_view = null;
			}
		}

		public function get paintingManager():PaintingManager {
			return _paintingManager;
		}

		public function get room():Room {
			return _room;
		}

		// ---------------------------------------------------------------------
		// Freezing.
		// ---------------------------------------------------------------------

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function renderScene( target:Texture ):void {

//			trace( this, "rendering 3d? enabled: " + _isEnabled + ", assets loaded: " + _assetsLoaded + ", view: " + _view );

			if( !_isEnabled ) return;
			if( !_view ) return;
			if( !_view.parent ) return;

			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering 3d" );
			}

			_scrollCameraController.update();
			_view.render( target );
		}

		public function get easelRect():Rectangle {
			var plane:Mesh = _paintingManager.easel.painting;
			var rect:Rectangle = HomeViewUtils.calculatePlaneScreenRect( plane, _view );
			// Uncomment to debug rect on screen.
			/*this.graphics.lineStyle( 1, 0xFF0000 );
			this.graphics.drawRect( rect.x * CoreSettings.GLOBAL_SCALING, rect.y * CoreSettings.GLOBAL_SCALING,
					rect.width * CoreSettings.GLOBAL_SCALING, rect.height * CoreSettings.GLOBAL_SCALING );
			this.graphics.endFill();*/
			return rect;
		}

		// ---------------------------------------------------------------------
		// Camera control.
		// ---------------------------------------------------------------------

		public function introAnimation():void {
			_scrollCameraController.jumpToSnapPointIndex( _paintingManager.homePaintingIndex );
			dockAtCurrentPainting();
			_zoomCameraController.animateToYZ( HomeSettings.DEFAULT_CAMERA_Y, HomeSettings.DEFAULT_CAMERA_Z, 1, 3 );
		}

		public function dockAtCurrentPainting():void {
			trace( this, "docking at painting: " + _scrollCameraController.positionManager.closestSnapPointIndex );
			var framedPainting:GalleryPainting = _paintingManager.getPaintingAtIndex( _scrollCameraController.positionManager.closestSnapPointIndex );
			var plane:Mesh = framedPainting.painting;
			var pos:Vector3D = HomeViewUtils.calculateCameraYZToFitPlaneOnViewport( plane, _view );
			_zoomCameraController.setYZ( pos.y, pos.z );
		}

		public function get zoomCameraController():ZoomCameraController {
			return _zoomCameraController;
		}

		public function get scrollCameraController():HScrollCameraController {
			return _scrollCameraController;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function selectScene( scene:ObjectContainer3D ):void {
			if( _currentScene && _view.scene.contains( _currentScene ) )
				_view.scene.removeChild( _currentScene );
			if( scene ) {
				_view.scene.addChild( scene );
				_currentScene = scene;
			}
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onZoomControllerChange():void {
			_scrollCameraController.dirtyZ();
		}

		private function onZoomComplete():void {
			zoomCompletedSignal.dispatch();
		}

		private function onClosestPaintingChanged( index:uint ):void {
			closestPaintingChangedSignal.dispatch( index );
		}

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
	}
}
