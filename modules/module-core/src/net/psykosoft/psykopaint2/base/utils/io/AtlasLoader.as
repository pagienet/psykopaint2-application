package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.BitmapData;

	public class AtlasLoader
	{
		private var _bitmapLoader:BitmapLoader;
		private var _descriptorLoader:XMLLoader;
		private var _bmd:BitmapData;
		private var _descriptorUrl:String;
		private var _finalCallback:Function;
		private var _imageUrl:String

		public function AtlasLoader() {
			super();
			_bitmapLoader = new BitmapLoader();
			_descriptorLoader = new XMLLoader();
		}

		public function loadAsset( imageUrl:String, descriptorUrl:String, callback:Function ):void {
			_descriptorUrl = descriptorUrl;
			_finalCallback = callback;
			_bitmapLoader.loadAsset( imageUrl, onBitmapLoaded );
		}

		public function dispose():void {
			_bmd = null; // Whoever grabs the bmd is in charge of disposing it.
			_bitmapLoader.dispose();
			_descriptorLoader.dispose();
			_bitmapLoader = null;
			_descriptorLoader = null;
			_imageUrl = null;
			_descriptorUrl = null;
		}

		private function onBitmapLoaded( bmd:BitmapData ):void {
			_bmd = bmd;
			_descriptorLoader.loadAsset( _descriptorUrl, onDescriptorLoaded );
		}

		private function onDescriptorLoaded( xml:XML ):void {
			trace( this, "loaded: " + _imageUrl + ", " + _descriptorUrl );
			_finalCallback( _bmd, xml );
		}
	}
}
