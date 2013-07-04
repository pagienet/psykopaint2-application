package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.book.views.book.objects.Book;
	import net.psykosoft.psykopaint2.book.views.book.objects.PageVO;

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
			_view.camera.position = new Vector3D( 0, 1000, -1000 );
			_view.camera.lookAt( new Vector3D() );
			addChild( _view );

			// -----------------------
			// Initialize objects.
			// -----------------------

			initializeBook();
		}

		private function initializeBook():void {

			// Initialize book.
			_book = new Book( stage, 512, 1024 );
			_view.scene.addChild( _book );

			// Sample page content.
			var samplePageContent:Sprite = new Sprite();
			samplePageContent.graphics.beginFill( 0xCCCCCC, 1.0 );
			samplePageContent.graphics.drawRect( 0, 0, _book.pageWidth, _book.pageHeight );
			samplePageContent.graphics.endFill();
			var tf:TextField = new TextField();
			var format:TextFormat = tf.defaultTextFormat;
			format.size = 120;
			tf.defaultTextFormat = format;
			tf.text = String( "hello" );
			tf.width += tf.textWidth * 1.1;
			tf.height += tf.textHeight * 1.1;
			samplePageContent.addChild( tf );

			// TODO: create some sort of content base that tiles images

			// Populate book.
			var len:uint = 40;
			for( var i:uint; i < len; ++i ) {
				var vo:PageVO = new PageVO();
				// Front page.
				if( i > 0 ) { // The 1st page doesn't have a front image ( book is always open ).
					vo.frontContent = samplePageContent;
				}
				// Back page.
				if( i < len - 1 ) { // The last page doesn't have a back image ( book is always open ).
					vo.backContent = samplePageContent;
				}
				_book.addPage( vo );
			}
			_book.updatePageContent();

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
