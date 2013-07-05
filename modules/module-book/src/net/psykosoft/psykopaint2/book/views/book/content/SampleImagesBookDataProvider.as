package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;

	import net.psykosoft.psykopaint2.base.utils.io.AtlasLoader;

	public class SampleImagesBookDataProvider extends BookDataProviderBase
	{
		private var _atlasDictionary:Dictionary;
		private var _indexForLoader:Dictionary;

		public function SampleImagesBookDataProvider() {
			super();
			_atlasDictionary = new Dictionary();
			_indexForLoader = new Dictionary();
		}

		private function loadAtlasForIndex( index:uint ):void {
			if( index < 1 ) { // Atm we only have 1 atlas.
				var loader:AtlasLoader = new AtlasLoader();
				loader.loadAsset( "/book-packaged/samples/samples.png", "/book-packaged/samples/samples.xml", onAtlasReady );
				_indexForLoader[ loader ] = index;
			}
		}

		private function onAtlasReady( loader:AtlasLoader ):void {
			var index:uint = _indexForLoader[ loader ];
			var atlas:BitmapAtlas = new BitmapAtlas( loader.bmd, loader.xml );
			_atlasDictionary[ index ] = atlas;
			generateSheetTextureForAtlas( atlas, index );
			loader.dispose();
			loader = null;
		}

		private function generateSheetTextureForAtlas( atlas:BitmapAtlas, index:uint ):void {
			var texBmd:BitmapData = new BitmapData( _sheetWidth, _sheetHeight, false, 0xFFFFFF );
			texBmd.draw( atlas.bmd );
			registerTextureForSheet( new BitmapTexture( texBmd ), index );
		}

		// ---------------------------------------------------------------------
		// Obligatory overrides.
		// ---------------------------------------------------------------------

		override protected function onSheetRequested( index:uint ):void {
			var atlas:BitmapAtlas = _atlasDictionary[ index ];
			if( atlas ) generateSheetTextureForAtlas( atlas, index );
			else loadAtlasForIndex( index );
		}

		override public function get numSheets():uint {
			return 2;
		}

		// ---------------------------------------------------------------------
		// Optional overrides.
		// ---------------------------------------------------------------------

		override protected function onDispose():void {
			// TODO
		}

		override protected function onDisposeSheetAtIndex( index:uint ):void {
//			trace( this, "disposing sheet: " + index );
			// Registered textures are automatically disposed, but you may want to dispose other sheet data here.
		}
	}
}
