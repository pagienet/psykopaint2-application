package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class BookView extends ViewBase
	{
		private var _stage3dProxy:Stage3DProxy;
		private var _view:View3D;

		public function BookView() {
			super();
			scalesToRetina = false;
		}

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
			setup();
		}

		override protected function onEnabled():void {

		}

		override protected function onDisabled():void {

		}

		override protected function onSetup():void {

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

			// -----------------------
			// Initialize objects.
			// -----------------------

			// Visualize scene origin.
//			var tri:Trident = new Trident( 500 );
//			_view.scene.addChild( tri );
			var something:Mesh = new Mesh( new CubeGeometry(), new ColorMaterial() );
			_view.scene.addChild( something );
		}

		public function renderScene():void {
			if( !_view.parent ) return;
			_view.render();
		}
	}
}
