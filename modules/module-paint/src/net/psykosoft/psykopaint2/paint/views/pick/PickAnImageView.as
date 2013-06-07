package net.psykosoft.psykopaint2.paint.views.pick
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.HPageScroller;
	import net.psykosoft.psykopaint2.base.utils.DesktopImageBrowser;
	import net.psykosoft.psykopaint2.base.utils.IosImagesFetcher;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	import org.osflash.signals.Signal;

	public class PickAnImageView extends ViewBase
	{
		private var _browser:DesktopImageBrowser;
		private var _iosUtil:IosImagesFetcher;
		private var _imageScroller:HPageScroller;
		private var _thumbX:Number;
		private var _thumbY:Number;
		private var _creatingPageNum:uint;
		private var _itemCount:uint;
		private var _cellSize:int;

		public var imagePickedSignal:Signal;

		public function PickAnImageView() {
			super();
			imagePickedSignal = new Signal();
		}

		override protected function onSetup():void {

			// Bg.
			graphics.beginFill( 0xFFFFFF, 1.0 );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();

			// Scroller.
			_imageScroller = new HPageScroller();
			_imageScroller.visibleHeight = 768;// * ( Settings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1);
			_imageScroller.visibleWidth = 1024;// * ( Settings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1);

			addChild( _imageScroller );

		}

		override protected function onEnabled():void {

			reset();

			if( !CoreSettings.RUNNING_ON_iPAD ) {
				_browser = new DesktopImageBrowser();
				_browser.browseForImage( onImagePickedFromDesktop );
			}
			else {
				_iosUtil = new IosImagesFetcher( CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 150 : 75 );
				_iosUtil.getThumbnailsLoadedSignal().add( onIosThumbnailSheetReady );
				_iosUtil.loadThumbnails();
			}
		}

		override protected function onDisabled():void {
			dispose();
		}

		override protected function onDisposed():void {
			// TODO: dispose everything...
		}

		private function reset():void {
			_imageScroller.reset();
			_thumbX = _thumbY = 0;
			_itemCount = 0;
			_creatingPageNum = 1;
		}

		private function onIosThumbnailSheetReady( vo:SheetVO ):void {

			trace( this, "iOS thumbnail sheet retrieved: " + vo.numberOfItems );

			var len:uint = vo.numberOfItems;
			var thumbSheetX:Number = 0;
			var thumbSheetY:Number = 0;

			var gap:Number = 20;
			_cellSize = vo.thumbSize + gap;
			var cols:int = _imageScroller.visibleWidth / _cellSize;
			var border:int = (_imageScroller.visibleWidth - ( _cellSize * cols) + gap) / 2;

			for( var i:uint; i < len; ++i ) {

				var bitmap:Bitmap = new Bitmap( vo.bmd );
				bitmap.scrollRect = new Rectangle( thumbSheetX, thumbSheetY, vo.thumbSize, vo.thumbSize );
				bitmap.x = border + _thumbX;
				bitmap.y = border + _thumbY;
				bitmap.opaqueBackground = 0xffffff;
				_imageScroller.addChild( bitmap );

				// Advance in sheet space.
				thumbSheetX += vo.thumbSize;
				if( thumbSheetX + vo.thumbSize >= vo.sheetSize ) {
					thumbSheetX = 0;
					thumbSheetY += vo.thumbSize;
				}

				// Advance in scroller space.
				_thumbX += vo.thumbSize + gap;
				if( border + _thumbX + vo.thumbSize > _creatingPageNum * _imageScroller.visibleWidth ) {
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.visibleWidth;
					_thumbY += vo.thumbSize + gap;
				}
				if( border + _thumbY + vo.thumbSize > _imageScroller.visibleHeight ) {
					_creatingPageNum++;
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.visibleWidth;
					_thumbY = 0;
				}

				_itemCount++;
			}

			_imageScroller.addEventListener( MouseEvent.MOUSE_DOWN, onSheetClick );
			_imageScroller.invalidateContent();
		}

		private function onSheetClick( event:MouseEvent ):void {
			_imageScroller.removeEventListener( MouseEvent.MOUSE_DOWN, onSheetClick );
			var column:int = _imageScroller.mouseX / _cellSize;
			var row:int = _imageScroller.mouseY / _cellSize;
			var thumbIndex:String = String( row * int( _imageScroller.visibleWidth / _cellSize ) + column );
			_iosUtil.getFullImageLoadedSignal().add( onIosFullImageRetrieved );
			_iosUtil.loadFullImage( thumbIndex );
		}

		private function onIosFullImageRetrieved( bmd:BitmapData ):void {
			imagePickedSignal.dispatch( bmd );
		}

		private function onImagePickedFromDesktop( bmd:BitmapData ):void {
			_browser.dispose();
			_browser = null;
			imagePickedSignal.dispatch( bmd );
		}
	}
}
