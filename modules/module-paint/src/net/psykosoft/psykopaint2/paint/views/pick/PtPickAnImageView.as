package net.psykosoft.psykopaint2.paint.views.pick
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.ui.BsViewBase;
	import net.psykosoft.psykopaint2.base.utils.BsDesktopImageBrowser;
	import net.psykosoft.psykopaint2.base.utils.BsIosImagesFetcher;
	import net.psykosoft.psykopaint2.core.config.CrSettings;
	import net.psykosoft.psykopaint2.core.views.components.CrHorizontalSnapScroller;

	import org.osflash.signals.Signal;

	public class PtPickAnImageView extends BsViewBase
	{
		private var _browser:BsDesktopImageBrowser;
		private var _iosUtil:BsIosImagesFetcher;
		private var _imageScroller:CrHorizontalSnapScroller;
		private var _thumbX:Number;
		private var _thumbY:Number;
		private var _creatingPageNum:uint;
		private var _itemCount:uint;
		private var _cellSize:int;
		
		public var imagePickedSignal:Signal;
		
		public function PtPickAnImageView() {
			super();
			imagePickedSignal = new Signal();
		}

		override protected function onSetup():void {

			// Bg.
			graphics.beginFill( 0xFFFFFF, 1.0 );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();

			// Scroller.
			_imageScroller = new CrHorizontalSnapScroller();
			_imageScroller.pageHeight = 768;// * ( Settings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1);
			_imageScroller.pageWidth = 1024;// * ( Settings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1);
			
			addChild( _imageScroller );
			
		}

		override protected function onEnabled():void {

			reset();

			if( !CrSettings.RUNNING_ON_iPAD ) {
				_browser = new BsDesktopImageBrowser();
				_browser.browseForImage( onImagePickedFromDesktop );
			}
			else {
				_iosUtil = new BsIosImagesFetcher( CrSettings.RUNNING_ON_RETINA_DISPLAY ? 150 : 75 );
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

		/*
		private function onIosThumbnailSheetReady( vo:SheetVO ):void {

			trace( this, "iOS thumbnail sheet retrieved: " + vo.numberOfItems );

			var len:uint = vo.numberOfItems;
			var thumbSheetX:Number = 0;
			var thumbSheetY:Number = 0;
			for( var i:uint; i < len; ++i ) {

				// Redraw portion of sheet.
				var bmd:BitmapData = new BitmapData( vo.thumbSize, vo.thumbSize, false, 0xFF0000 );
				var matrix:Matrix = new Matrix();
				matrix.translate( -thumbSheetX, -thumbSheetY );
				bmd.draw( vo.bmd, matrix );

				// Advance in sheet space.
				thumbSheetX += vo.thumbSize;
				if( thumbSheetX + vo.thumbSize >= vo.sheetSize ) {
					thumbSheetX = 0;
					thumbSheetY += vo.thumbSize;
				}

				// Contain drawing in display object.
				var spr:Sprite = new Sprite();
				var bitmap:Bitmap = new Bitmap( bmd );
				spr.addEventListener( MouseEvent.MOUSE_DOWN, onThumbClick );
				spr.x = _thumbX;
				spr.y = _thumbY;
				spr.addChild( bitmap );
				spr.name = "item_" + _itemCount;
				_imageScroller.addChild( spr );

				// Advance in scroller space.
				var gap:Number = 20;
				_thumbX += vo.thumbSize + gap;
				if( _thumbX + vo.thumbSize > _creatingPageNum * _imageScroller.pageWidth ) {
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.pageWidth;
					_thumbY += vo.thumbSize + gap;
				}
				if( _thumbY + vo.thumbSize > _imageScroller.pageHeight ) {
					_creatingPageNum++;
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.pageWidth;
					_thumbY = 0;
				}

				_itemCount++;
			}

			_imageScroller.invalidateContent();
		}
		*/
		private function onIosThumbnailSheetReady( vo:SheetVO ):void {
			
			trace( this, "iOS thumbnail sheet retrieved: " + vo.numberOfItems );
			
			var len:uint = vo.numberOfItems;
			var thumbSheetX:Number = 0;
			var thumbSheetY:Number = 0;
			
			var gap:Number = 20;
			_cellSize =  vo.thumbSize + gap;
			var cols:int = _imageScroller.pageWidth / _cellSize;
			var border:int = (_imageScroller.pageWidth - ( _cellSize * cols) + gap) / 2;
			
			
			for( var i:uint; i < len; ++i ) {
				
				
				var bitmap:Bitmap = new Bitmap( vo.bmd );
				bitmap.scrollRect = new Rectangle(thumbSheetX,thumbSheetY,vo.thumbSize,vo.thumbSize);
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
				if( border + _thumbX + vo.thumbSize > _creatingPageNum * _imageScroller.pageWidth ) {
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.pageWidth;
					_thumbY += vo.thumbSize + gap;
				}
				if( border + _thumbY + vo.thumbSize > _imageScroller.pageHeight ) {
					_creatingPageNum++;
					_thumbX = ( _creatingPageNum - 1 ) * _imageScroller.pageWidth;
					_thumbY = 0;
				}
				
				_itemCount++;
			}
			
			_imageScroller.addEventListener( MouseEvent.MOUSE_DOWN, onSheetClick );
			_imageScroller.invalidateContent();
		}

/*
		private function onThumbClick( event:MouseEvent ):void {
			var thumb:Sprite = event.target as Sprite;
			var thumbIndex:String = thumb.name.split( "_" )[ 1 ];
			_iosUtil.getFullImageLoadedSignal().add( onIosFullImageRetrieved );
			_iosUtil.loadFullImage( thumbIndex );
		}
*/
		
		private function onSheetClick( event:MouseEvent ):void {
			
			_imageScroller.removeEventListener( MouseEvent.MOUSE_DOWN, onSheetClick );
			var column:int = _imageScroller.mouseX / _cellSize;
			var row:int = _imageScroller.mouseY / _cellSize;
			var thumbIndex:String = String( row * int( _imageScroller.pageWidth / _cellSize ) + column );
			_iosUtil.getFullImageLoadedSignal().add( onIosFullImageRetrieved );
			_iosUtil.loadFullImage( thumbIndex );
		}
		
		private function onIosFullImageRetrieved( bmd:BitmapData ):void {
			// TODO: loose all thumb data
			// TODO: notify with full image bmd
			/*
			while ( _imageScroller.numChildren > 0 ) {
				var dob:DisplayObject = _imageScroller.removeChildAt(0);
				if ( dob is Bitmap ) Bitmap(dob).bitmapData.dispose();
			}
			*/
			
			imagePickedSignal.dispatch( bmd );
		}
		
		

		private function onImagePickedFromDesktop( bmd:BitmapData ):void {
			_browser.dispose();
			_browser = null;
			imagePickedSignal.dispatch( bmd );
		}
	}
}
