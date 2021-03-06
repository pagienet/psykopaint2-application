package net.psykosoft.psykopaint2.home.views.home
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import away3d.Away3D;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Object3DEvent;
	import away3d.filters.SmartDepthOfFieldFilter3D;
	import away3d.lights.PointLight;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.views.book.BookView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryView;
	import net.psykosoft.psykopaint2.home.views.home.atelier.Atelier;
	import net.psykosoft.psykopaint2.home.views.home.controllers.CameraPromenadeController;
	import net.psykosoft.psykopaint2.home.views.home.controllers.OrientationBasedController;
	
	import org.osflash.signals.Signal;

	public class HomeView extends ViewBase
	{
		public static var SETTINGS : int = 0;
		public static var EASEL : int = 1;
		public static var HOME : int = 2;
		public static var GALLERY : int = 3;
		public static var CROP : int = 4;

		public var activeSectionChanged : Signal = new Signal();
		public var distanceToSectionChanged : Signal = new Signal();
		public var sceneReadySignal : Signal = new Signal();

		private var _lightController : OrientationBasedController;
		private var _cameraController : CameraPromenadeController;
		private var _light : PointLight;
		private var _view : View3D;
		private var _stage3dProxy : Stage3DProxy;
		private var _easelView : EaselView;
		private var _roomView : RoomView;
		private var _galleryView : GalleryView;
		private var _bookView : BookView;

		private var _atelier : Atelier;
		private var _camera : Camera3D;
		private var _scrollingEnabled : Boolean = true;
		private var _animateToTarget : Boolean = false;
		private var _depthOfFieldFilter : SmartDepthOfFieldFilter3D;

		public function HomeView()
		{

		}

		public function get bookView():BookView
		{
			return _bookView;
		}

		public function get scrollingEnabled() : Boolean
		{
			return _scrollingEnabled;
		}

		public function set scrollingEnabled(value : Boolean) : void
		{
			if (_scrollingEnabled == value) return;
			_scrollingEnabled = value;
			if (_scrollingEnabled)
				_cameraController.start();
			else
				_cameraController.stop();
		}

		public function get stage3dProxy() : Stage3DProxy
		{
			return _stage3dProxy;
		}

		public function set stage3dProxy(value : Stage3DProxy) : void
		{
			_stage3dProxy = value;
		}

		public function playIntroAnimation(onComplete : Function,speed:Number=1) : void
		{
			initCameraIntroPosition();
			
			TweenLite.to(	_camera, speed, { 	z:450,
				delay:speed/8,
				ease: Expo.easeOut,
				onComplete:onComplete,
				overwrite : 0
			} );
		}

		override protected function onEnabled() : void
		{
			initScene();
			initSubViews();
			initLightController();
		}

		override protected function onDisabled() : void
		{
			destroyScene();
			destroySubViews();
		}

		private function initScene() : void
		{
			trace("Away3D VERSION = "+Away3D.MAJOR_VERSION+"."+Away3D.MINOR_VERSION+"."+Away3D.REVISION);

			initView();
			initCamera();
			initLight();
			initModel();
		}

		private function initLightController() : void
		{
			var matrix : Matrix3D = new Matrix3D();
			var center : Vector3D = EaselView.CANVAS_DEFAULT_POSITION;
			matrix.appendRotation(180, Vector3D.Y_AXIS);
			matrix.appendTranslation(center.x, center.y, center.z);

			_lightController = new OrientationBasedController(_light);
			_lightController.neutralOffset = new Vector3D(0, 0, -1000);
			_lightController.postMatrix = matrix;
		}

		private function initModel() : void
		{
			_atelier = new Atelier(_stage3dProxy);
			_atelier.mouseEnabled = false;
			_atelier.mouseChildren = false;
			_atelier.addEventListener(Event.COMPLETE, onAtelierComplete);
			_atelier.init();
		}

		private function onAtelierComplete(event : Event) : void
		{
			_view.scene.addChild(_atelier);
			_atelier.removeEventListener(Event.COMPLETE, onAtelierComplete);

			sceneReadySignal.dispatch();
		}

		private function initSubViews() : void
		{
			// this is a bit shitty, but it'd suck to have to create an entire mediator system for Away3D components, so... we cheat
			_easelView = new EaselView(_view, _light, _stage3dProxy);
			_roomView = new RoomView(_atelier, _stage3dProxy);
			_galleryView = new GalleryView(_view, _light, _stage3dProxy);
			_bookView = new BookView(_view, _light, _stage3dProxy);
			addChild(_easelView);
			addChild(_roomView);
			addChild(_galleryView);
			addChild(_bookView);
		}

		private function initView() : void
		{
			_view = new View3D();
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.rethrowEvents = false;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;

			_depthOfFieldFilter = new SmartDepthOfFieldFilter3D(10 * CoreSettings.GLOBAL_SCALING, 10 * CoreSettings.GLOBAL_SCALING, CoreSettings.GLOBAL_SCALING);
			_depthOfFieldFilter.smartRange = 220;
			_depthOfFieldFilter.range = 100;

			stage.addChildAt( _view, 0 );

		}

		private function initCamera() : void
		{
			_camera = _view.camera;
			_camera.lens.near = 10;
			_camera.lens.far = 1000;
			_camera.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraMoved);
			PerspectiveLens( _view.camera.lens ).fieldOfView = 60;
			initCameraIntroPosition();

			_cameraController = new CameraPromenadeController(_camera, stage);
			_cameraController.activePositionChanged.add(onActivePositionChanged);
			_cameraController.distanceToTargetChanged.add(onDistanceToTargetChanged);
			_cameraController.registerTargetPosition(SETTINGS, new Vector3D(814, -1.14, 450));
			_cameraController.registerTargetPosition(EASEL, EaselView.CAMERA_POSITION);
			_cameraController.registerTargetPosition(HOME, new Vector3D(-271, -1.14, 450));
			_cameraController.registerTargetPosition(GALLERY, GalleryView.CAMERA_FAR_POSITION);
			//_cameraController.registerTargetPosition(CROP, new Vector3D(271, -40, 170));
			_cameraController.registerTargetPosition(CROP, EaselView.CAMERA_POSITION);
			//_cameraController.start();
			_cameraController.interactionRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight - 150*CoreSettings.GLOBAL_SCALING);
		}

		private function onCameraMoved(event:Object3DEvent):void
		{
			if (_depthOfFieldFilter && _easelView)
				_depthOfFieldFilter.focusDistance = Math.abs(_easelView.canvasScenePosition.z - _camera.scenePosition.z) + 50;
		}

		private function initCameraIntroPosition():void
		{
			_camera.x =  -266.82;
			_camera.y = -1.14;
			_camera.z = -146.5;
			
			_camera.lookAt(new Vector3D(-266.82, -1.14, -353.10));
		}

		private function onActivePositionChanged() : void
		{
			activeSectionChanged.dispatch(_cameraController.activeTargetPositionID);
		}

		private function onDistanceToTargetChanged(dis:Number):void {
			distanceToSectionChanged.dispatch(dis);
		}

		private function initLight() : void
		{
			_light = new PointLight();
			_light.ambient = 1;
			_light.color = 0x989589;
			_light.ambientColor = 0x808088;
			_light.specular = .25;
		}

		public function renderScene(target : Texture) : void
		{
			_lightController.neutralOffset.x = -_camera.x;
			_lightController.update();
			_view.render(target);
		}

		private function destroyScene() : void
		{
			_view.scene.removeChild(_atelier);
			_camera.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onCameraMoved);
			_atelier.dispose();
			_light.dispose();
			_view.dispose();
			_view.parent.removeChild(_view);
			_cameraController.stop();
			_cameraController.activePositionChanged.remove(onActivePositionChanged);
			_cameraController.distanceToTargetChanged.remove(onDistanceToTargetChanged);
			_atelier = null;
			_light = null;
			_view = null;
			_lightController = null;
			_cameraController = null;

			_depthOfFieldFilter.dispose();
		}

		private function destroySubViews() : void
		{
			_easelView.dispose();
			removeChild(_easelView);
			
			removeChild(_roomView);
			
			//MATHIEU: I THINK WE COULD DISPOSE OF THE GALLERY ALREADY IF WE'RE IN PAINT VIEW
			_galleryView.dispose();
			removeChild(_galleryView);
			
			
			//THE BOOK IS AUTOMATICALLY DISPOSED WHEN REMOVED FROM STAGE:
			//removeChild(_bookView);
			
			
			_easelView = null;
			_roomView = null;
			_galleryView = null;
			_bookView = null;
		}

		public function setOrientationMatrix(orientationMatrix : Matrix3D) : void
		{
			_lightController.orientationMatrix = orientationMatrix;
		}

		public function get activeSection() : int
		{
			return _cameraController.activeTargetPositionID;
		}

		public function forceSection(section : int) : void
		{
			_cameraController.force(section);
		}

		public function set activeSection(activeSection : int) : void
		{
			if (_animateToTarget) {
				_cameraController.navigateTo(activeSection);
			}
			else {
				_animateToTarget = true;
				_cameraController.force(activeSection);
			}
		}

		public function updateProfilePicture(bitmapData:BitmapData):void
		{
			_atelier.setIconImage(bitmapData);
		}
		
		public function activateCameraControl():void
		{
			_cameraController.start();
		}

		public function setDepthOfFieldEnabled(state : Boolean):void
		{
			_view.filters3d = state? [ _depthOfFieldFilter ] : [];
		}
	}
}
