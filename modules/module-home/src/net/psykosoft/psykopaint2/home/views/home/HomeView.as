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
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;

	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.views.home.camera.HScrollCameraController;
	import net.psykosoft.psykopaint2.home.views.home.camera.ZoomCameraController;
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
		private var _light:PointLight;
		private var _lightPicker:StaticLightPicker;
		private var _mainScene:ObjectContainer3D;
		private var _currentScene:ObjectContainer3D;

		public var closestSnapPointChangedSignal:Signal;
		public var zoomCompletedSignal:Signal;
		public var easelRectChanged:Signal;
		public var sceneReadySignal:Signal;
		private var _targetLightPosition : Vector3D = new Vector3D(0, 0, -1);
		private var _lightInterpolation : Number = .99;

		public function HomeView() {
			super();
			scalesToRetina = false;
			closestSnapPointChangedSignal = new Signal();
			zoomCompletedSignal = new Signal();
			easelRectChanged = new Signal();
			sceneReadySignal = new Signal();
		}

		// ---------------------------------------------------------------------
		// Build/destroy.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {
			buildScene();
		}

		override protected function onDisabled():void {
			destroyScene();
		}

		private function buildScene():void {

//			trace( this, "building scene..." );
//			var time:uint;
//			var methodTime:uint = getTimer();

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
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown, false, 0, true );
			stage.addEventListener( KeyboardEvent.KEY_UP, onStageKeyUp, false, 0, true );

			// -----------------------
			// Scenes.
			// -----------------------

			_mainScene = new ObjectContainer3D();
			selectScene( _mainScene );

			// -----------------------
			// Initialize objects.
			// -----------------------

			_light = new PointLight();
			// TODO: Use gyromoscope on this too?
			_light.position = new Vector3D( 1500 * .8, 1500 * .8, -750 - 1750 * .8 );
			_light.ambient = 1;
			_light.color = 0x989589;
			_light.ambientColor = 0x808088;
			_lightPicker = new StaticLightPicker( [_light] );
			_room = new Room( _view, _stage3dProxy );

			var cameraTarget:Object3D = new Object3D();
			_scrollCameraController = new HScrollCameraController();
			_zoomCameraController = new ZoomCameraController();
			_scrollCameraController.closestSnapPointChangedSignal.add( onClosestSnapPointChanged );
			_zoomCameraController.zoomCompleteSignal.add( onZoomComplete );
			_scrollCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.setCamera( _view.camera, cameraTarget );
			_zoomCameraController.setYZ( HomeSettings.DEFAULT_CAMERA_Y, HomeSettings.DEFAULT_CAMERA_Z );
			_zoomCameraController.yzChangedSignal.add( onZoomControllerChange );
			_view.camera.addEventListener( Object3DEvent.SCENETRANSFORM_CHANGED, onCameraSceneTransformChanged, false, 0, true );
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
//			time = getTimer();
			_paintingManager.createDefaultPaintings();
//			trace( this, "time taken to init paintings: " + String( getTimer() - time ) );
			_scrollCameraController.positionManager.pushSnapPoint(6000);

			// Always start at easel.
			_scrollCameraController.jumpToSnapPointIndex( 1 );

			// TODO: needed? - it seems to be required for a correct positioning for 1st zoom out
//			time = getTimer();
			_stage3dProxy.clear();
			_view.render();


//			trace( this, "time taken for first render: " + String( getTimer() - time ) );

//			trace( this, "method time: " + String( getTimer() - methodTime ) );

			sceneReadySignal.dispatch();
		}

		private function updateLightPosition() : void
		{
			var pos : Vector3D = _light.position;
			var targetX : Number = _targetLightPosition.x + _paintingManager.easel.scenePosition.x;
			var targetY : Number = _targetLightPosition.y + _paintingManager.easel.scenePosition.y;
			var targetZ : Number = _targetLightPosition.z + _paintingManager.easel.scenePosition.z;
			pos.x += (targetX - pos.x) * _lightInterpolation;
			pos.y += (targetY - pos.y) * _lightInterpolation;
			pos.z += (targetZ - pos.z) * _lightInterpolation;
			_light.position = pos;
		}

		private function destroyScene():void {

			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
			stage.removeEventListener( KeyboardEvent.KEY_UP, onStageKeyUp );

			if( _room ) {
				_mainScene.removeChild( _room );
				_room.dispose();
				_room = null;
			}

			if( _paintingManager ) {
				_mainScene.removeChild( _paintingManager );
				_paintingManager.dispose();
				_paintingManager = null;
			}

			if( _scrollCameraController ) {
				_scrollCameraController.closestSnapPointChangedSignal.remove( onClosestSnapPointChanged );
				_scrollCameraController.dispose();
				_scrollCameraController = null;
			}

			if( _zoomCameraController ) {
				_zoomCameraController.yzChangedSignal.remove( onZoomControllerChange );
				_zoomCameraController.zoomCompleteSignal.remove( onZoomComplete );
				_zoomCameraController.dispose();
				_zoomCameraController = null;
			}

			if( _light ) {
				_mainScene.removeChild( _light );
				_light.dispose();
				_light = null;
			}

			if( _lightPicker ) {
				_lightPicker.dispose();
			}

			if( _mainScene ) {
				_view.scene.removeChild( _mainScene );
				_mainScene.dispose();
				_mainScene = null;
			}

			if( _view ) {
				_view.camera.removeEventListener( Object3DEvent.SCENETRANSFORM_CHANGED, onCameraSceneTransformChanged );
				removeChild( _view );
				_view.dispose();
				_view = null;
			}

			if( _stage3dProxy ) {
				_stage3dProxy = null;
			}
		}

		// ---------------------------------------------------------------------
		// Updates.
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
			updateLightPosition();
			_view.render( target );
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

		private function onClosestSnapPointChanged( index:uint ):void {
			closestSnapPointChangedSignal.dispatch( index );
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
//			trace( this, "positioning camera, Y: " + _view.camera.y + ", Z: " + _view.camera.z );
		}

		private function onCameraSceneTransformChanged( event:Object3DEvent ):void {
//			trace( this, "onCameraSceneTransformChanged()" );
			easelRectChanged.dispatch();
		}

		// ---------------------------------------------------------------------
		// Getters & setters.
		// ---------------------------------------------------------------------

		public function get paintingManager():PaintingManager {
			return _paintingManager;
		}

		public function get room():Room {
			return _room;
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

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
		}

		public function get targetLightPosition() : Vector3D
		{
			return _targetLightPosition;
		}

		public function set targetLightPosition(value : Vector3D) : void
		{
			_targetLightPosition = value;
		}
	}
}
