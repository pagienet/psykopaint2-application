package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display3D.textures.Texture;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.book.views.book.objects.Book;

	import org.osflash.signals.Signal;

	public class BookView extends ViewBase
	{
		private var _stage3dProxy:Stage3DProxy;
		private var _view:View3D;
		private var _book:Book;
		private var _origin:Vector3D;

		private const BOOK_Y:Number = 200;

		public var animateOutCompleteSignal:Signal;
		public var animateInCompleteSignal:Signal;

		public function BookView() {
			super();
			scalesToRetina = false;
			animateOutCompleteSignal = new Signal();
			animateInCompleteSignal = new Signal();
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
			_book.y = -2048;
			_view.scene.addChild( _book );

			// Interaction.
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		public function animateIn():void {
			TweenLite.to( _book, 0.75, { y: BOOK_Y, delay: 1.5, ease: Strong.easeOut, onComplete: onAnimateInComplete } );
		}

		public function animateOut():void {
			TweenLite.to( _book, 0.75, { y: -2048, ease: Strong.easeIn, onComplete: onAnimateOutComplete } );
		}

		private function onAnimateInComplete():void {
			animateInCompleteSignal.dispatch();
		}

		private function onAnimateOutComplete():void {
			animateOutCompleteSignal.dispatch();
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

		public function renderScene(target : Texture):void {

			if( !_isEnabled ) return;
			if( !_view ) return;
			if( !_view.parent ) return;
			if( !_book.dataProvider ) return;

//			var target:Number = -75 + 15 * mouseY / 768;
//			_book.rotationX += ( target - _book.rotationX ) * 0.25;

			_book.update();
			_view.render(target);
		}

		public function get book():Book {
			return _book;
		}
	}
}
