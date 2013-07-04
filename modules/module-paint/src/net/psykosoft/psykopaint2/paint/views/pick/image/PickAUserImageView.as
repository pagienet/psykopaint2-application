package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageBrowser;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.tilesheet.UserPhotosTileSheet;

	import org.osflash.signals.Signal;

	public class PickAUserImageView extends ViewBase
	{
		private var _browser:DesktopImageBrowser;
		private var _tileSheet:UserPhotosTileSheet;

		public var imagePickedSignal:Signal;

		public function PickAUserImageView() {
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
				_tileSheet.setVisibleDimensions( 1024, 768 );
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
