package net.psykosoft.psykopaint2.base.utils
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;

	public class BsDesktopImageBrowser
	{
		private var _file:File;
		private var _loader:BsBitmapLoader;
		private var _onCompleteCallback:Function;

		public function BsDesktopImageBrowser() {
			super();
		}

		public function browseForImage( onCompleteCallback:Function ):void {
			_onCompleteCallback = onCompleteCallback;
			// Open a file dialog with image file filtering.
			_file = new File( File.desktopDirectory.url );
			_file.addEventListener( Event.SELECT, onFileSelect );
			_file.addEventListener( Event.CANCEL, onCancel );
			var fileFilter:FileFilter = new FileFilter( "Images", "*.jpg;*.jpeg;*.gif;*.png" );
			_file.browseForOpen( "Open an image file", [ fileFilter ] );
		}

		private function onCancel( event:Event ):void {
			_onCompleteCallback( null );
		}

		public function dispose():void {
			if( _file ) {
				if( _file.hasEventListener( Event.SELECT ) ) _file.removeEventListener( Event.SELECT, onFileSelect );
				if( _file.hasEventListener( Event.CANCEL ) ) _file.removeEventListener( Event.CANCEL, onCancel );
				_file = null;
			}
			if( _loader ) {
				_loader.dispose();
				_loader = null;
			}
			_onCompleteCallback = null;
		}

		private function onFileSelect( event:Event ):void {
			// Request image load.
			_loader = new BsBitmapLoader();
			_loader.loadAsset( _file.url, onLoaderDone );
		}

		private function onLoaderDone( bmd:BitmapData ):void {
			_onCompleteCallback( bmd );
		}
	}
}
