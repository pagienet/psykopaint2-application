package net.psykosoft.psykopaint2.home.views.home
{
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;

	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.home.views.home.atelier.Atelier;
	import net.psykosoft.psykopaint2.home.views.home.controllers.OrientationBasedController;

	import org.osflash.signals.Signal;

	public class HomeView extends ViewBase
	{
		public var sceneReadySignal : Signal = new Signal();

		private var _lightController : OrientationBasedController;
		private var _light : PointLight;
		private var _view : View3D;
		private var _stage3dProxy : Stage3DProxy;
		private var _easelView : EaselView;
		private var _roomView : RoomView;
		private var _galleryView : GalleryView;
		private var _easel : Mesh;
		private var _room : Mesh;
		private var _gallery : Mesh;
		private var _atelier : Atelier;

		public function HomeView()
		{

		}

		public function get stage3dProxy() : Stage3DProxy
		{
			return _stage3dProxy;
		}

		public function set stage3dProxy(value : Stage3DProxy) : void
		{
			_stage3dProxy = value;
		}

		public function playIntroAnimation() : void
		{

		}

		override protected function onEnabled() : void
		{
			initScene();
			initSubViews();
		}

		override protected function onDisabled() : void
		{
			destroyScene();
			destroySubViews();
		}

		private function initScene() : void
		{
			initView();
			initLight();
			initModel();
		}

		private function initModel() : void
		{
			_atelier = new Atelier();
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
			_easelView = new EaselView(_easel);
			_roomView = new RoomView(_room);
			_galleryView = new GalleryView(_gallery);
			addChild(_easelView);
			addChild(_roomView);
			addChild(_galleryView);
		}

		private function initView() : void
		{
			_view = new View3D();
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_view.camera.lens.far = 50000;
			addChild( _view );
			PerspectiveLens( _view.camera.lens ).fieldOfView = 70;
		}

		private function initLight() : void
		{
			_light = new PointLight();
			_lightController = new OrientationBasedController(_light);
//			_lightController.centerPosition = _easel.scenePosition;
			_lightController.neutralOffset = new Vector3D(0, 0, -1000);
		}

		public function renderScene(target : Texture) : void
		{
			_lightController.update();
			_view.render(target);
		}

		private function destroyScene() : void
		{
			_view.scene.removeChild(_atelier);
			_atelier.dispose();
			_light.dispose();
			_view.dispose();
			_atelier = null;
			_light = null;
			_view = null;
			_lightController = null;
		}

		private function destroySubViews() : void
		{
			removeChild(_easelView);
			removeChild(_roomView);
			removeChild(_galleryView);
			_easelView = null;
			_roomView = null;
			_galleryView = null;
		}

		public function setOrientationMatrix(orientationMatrix : Matrix3D) : void
		{
			_lightController.orientationMatrix = orientationMatrix;
		}
	}
}
