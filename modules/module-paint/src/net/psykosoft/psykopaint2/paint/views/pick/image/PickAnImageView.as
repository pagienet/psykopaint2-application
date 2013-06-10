package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.HPageScroller;
	import net.psykosoft.psykopaint2.base.utils.DesktopImageBrowser;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.tilesheet.UserPhotosTileSheet;

	import org.osflash.signals.Signal;

	public class PickAnImageView extends ViewBase
	{
		private var _browser:DesktopImageBrowser;
		private var _tileSheet:UserPhotosTileSheet;

		public var imagePickedSignal:Signal;

		public function PickAnImageView() {
			super();
			imagePickedSignal = new Signal();
		}

		override protected function onSetup():void {
			graphics.beginFill( 0x666666, 1.0 );
			graphics.drawRect( 0, 0, 1024, 768 );
			graphics.endFill();
		}

		override protected function onEnabled():void {
			if( !CoreSettings.RUNNING_ON_iPAD ) {
				_browser = new DesktopImageBrowser();
				_browser.browseForImage( onImagePickedFromDesktop );
			}
			else {
				_tileSheet = new UserPhotosTileSheet();
				_tileSheet.visibleWidth = 1024;
				_tileSheet.visibleHeight = 768;
				_tileSheet.fullImageFetchedSignal.add( onIosFullImageRetrieved );
				stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				addChild( _tileSheet );
				_tileSheet.fetchPhotos();
			}
		}

		override protected function onDisposed():void {
			if( _tileSheet ) {
				_tileSheet.fullImageFetchedSignal.remove( onIosFullImageRetrieved );
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
				_tileSheet.dispose();
				removeChild( _tileSheet );
				_tileSheet = null;
			}
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_tileSheet.evaluateInteractionEnd();
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_tileSheet.evaluateInteractionStart();
		}

		override protected function onDisabled():void {
			dispose();
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
