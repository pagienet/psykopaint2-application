package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageBrowser;
	
	import org.osflash.signals.Signal;

	public class PickAUserImageView extends ViewBase
	{
		private var _browser:DesktopImageBrowser;

		public var imagePickedSignal:Signal;

		public function PickAUserImageView() {
			super();
			imagePickedSignal = new Signal();
		}

		override protected function onSetup():void {
		}

		override protected function onEnabled():void {
			_browser = new DesktopImageBrowser();
			_browser.browseForImage( onImagePickedFromDesktop );
		}

		override protected function onDisabled():void {
			dispose();
		}

		private function onImagePickedFromDesktop( bmd:BitmapData ):void {
			_browser.dispose();
			_browser = null;
			imagePickedSignal.dispatch( bmd, CameraRollImageOrientation.ROTATION_0 );
		}
	}
}
