package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.book.views.book.objects.Book;

	public class BookView extends ViewBase
	{
		private var _stage3dProxy:Stage3DProxy;
		private var _view:View3D;
		private var _book:Book;
		private var _origin:Vector3D;

		public function BookView() {
			super();
			scalesToRetina = false;
			_origin = new Vector3D();
		}

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void {
			_stage3dProxy = stage3dProxy;
			setup();
		}

		override protected function onEnabled():void {

			// Initialize view.
			_view = new View3D();
			_view.stage3DProxy = _stage3dProxy;
			_view.shareContext = true;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_view.camera.lens.far = 5000;
			_view.camera.position = new Vector3D( 0, 0, -1350 );
			_view.camera.lookAt( _origin );
			addChild( _view );

			// Initialize book.
			_book = new Book( stage, 1024, 1024 );
			_book.rotationX = -75;
			_view.scene.addChild( _book );
		}

		override protected function onDisabled():void {

			// Dispose book.
			_view.scene.removeChild( _book );
			_book.dispose();

			// Dispose view.
			_view.dispose();
			removeChild( _view );

			// Clean up interaction.
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_book.startInteraction();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_book.stopInteraction();
		}

		public function renderScene():void {

			if( !_isEnabled ) return;
			if( !_view ) return;
			if( !_view.parent ) return;
			if( !_book.dataProvider ) return;

			var target:Number = -75 + 15 * mouseY / 768;
			_book.rotationX += ( target - _book.rotationX ) * 0.25;

			_book.update();
			_view.render();
		}

		public function get book():Book {
			return _book;
		}
	}
}
