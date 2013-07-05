package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.book.views.book.content.NumericBookDataProvider;
	import net.psykosoft.psykopaint2.book.views.book.objects.Book;
	import net.psykosoft.psykopaint2.book.views.book.content.BookDataProviderBase;

	public class BookView extends ViewBase
	{
		private var _stage3dProxy:Stage3DProxy;
		private var _view:View3D;
		private var _book:Book;

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
			_view.camera.position = new Vector3D( 0, 1500, -600 );
			_view.camera.lookAt( new Vector3D() );
			addChild( _view );

			// -----------------------
			// Initialize objects.
			// -----------------------

			initializeBook();
		}

		private function initializeBook():void {

			// Initialize book.
			// TODO: ability to have non power of 2 pages
			_book = new Book( stage, 1024, 1024 );
			_book.y = 350;
			_view.scene.addChild( _book );

			// Set book data provider.
			_book.dataProvider = new NumericBookDataProvider( _book.pageWidth, _book.pageHeight );

			// Interaction.
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_book.startInteraction();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_book.stopInteraction();
		}

		public function renderScene():void {
			if( !_view.parent ) return;
			_book.update();
			_view.render();
		}
	}
}