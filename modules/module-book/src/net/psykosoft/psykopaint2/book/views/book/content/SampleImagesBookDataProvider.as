package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.textures.BitmapTexture;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.base.utils.io.AtlasLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;

	import org.osflash.signals.Signal;

	public class SampleImagesBookDataProvider extends BookDataProviderBase
	{
		private var _atlas:BitmapAtlas;
		private var _thumbsPerSheet:uint;
		private var _numRows:uint;
		private var _numColumns:uint;
		private var _cellSize:uint;
		private var _numThumbs:uint;
		private var _numSheets:uint;
		private var _interactionRegionsForSheet:Dictionary;
		private var _thumbNameForRegion:Dictionary;
		private var _imageLoader:BitmapLoader;

		public var readySignal:Signal;
		public var fullImagePickedSignal:Signal;

		private const THUMB_SIZE:uint = 200;
		private const THUMB_GAP:uint = 20;

		public function SampleImagesBookDataProvider() {
			super();
			readySignal = new Signal();
			fullImagePickedSignal = new Signal();
			_interactionRegionsForSheet = new Dictionary();
			_thumbNameForRegion = new Dictionary();
			loadThumbnailsAtlas();
		}

		private function loadThumbnailsAtlas():void {
			var loader:AtlasLoader = new AtlasLoader();
			var date:Date = new Date();
			var cacheAnnihilator:String = "?t=" + String( date.getTime() ) + Math.round( 1000 * Math.random() );
			loader.loadAsset( "/book-packaged/samples/samples.png", "/book-packaged/samples/samples.xml" + cacheAnnihilator, onAtlasReady );
		}

		private function onAtlasReady( loader:AtlasLoader ):void {
			_atlas = new BitmapAtlas( loader.bmd, loader.xml );
			loader.dispose();
			loader = null;
			evaluateFigures();
			readySignal.dispatch();
		}

		private function evaluateFigures():void {
			_cellSize = THUMB_SIZE + THUMB_GAP;
			_numColumns = Math.floor( _sheetWidth / _cellSize );
			_numRows = Math.floor( _sheetHeight / _cellSize );
			_thumbsPerSheet = _numColumns * _numRows;
			_numThumbs = _atlas.getNumItems();
			_numSheets = Math.ceil( _numThumbs / _thumbsPerSheet );
			if( _numSheets % 2 != 0 ) _numSheets++; // Need to provide an even number of sheets for the book.
			trace( this, "num thumbs: " + _numThumbs );
			trace( this, "num columns: " + _numColumns );
			trace( this, "num rows: " + _numRows );
			trace( this, "num per sheet: " + _thumbsPerSheet );
			trace( this, "num sheets: " + _numSheets );
		}

		private function generateSheetForIndices( firstThumbIndex:uint, lastThumbIndex:uint, sheetIndex:uint ):void {

			trace( this, "generating sheet " + sheetIndex + " for thumb indices from " + firstThumbIndex + ", " + lastThumbIndex + " -----------------------" );

			// Produces a sprite containing the thumbnails as bitmaps.
			var i:uint;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			var drawSprite:Sprite = new Sprite();
			var thumbNames:Vector.<String> = _atlas.names;
			var regions:Vector.<Rectangle> = new Vector.<Rectangle>();
			for( i = firstThumbIndex; i < lastThumbIndex; i++ ) {

				// Id thumb name.
				var thumbName:String = thumbNames[ i ];
				trace( "thumb at " + i + " is named " + thumbName );

				// Produce a bitmap that wraps the thumbnail.
				var thumbBitmap:Bitmap = new Bitmap( _atlas.bmd );
				thumbBitmap.x = offsetX;
				thumbBitmap.y = offsetY;
				var sourceRegion:Rectangle = _atlas.getRegionForId( thumbName );
				thumbBitmap.scrollRect = sourceRegion;
				drawSprite.addChild( thumbBitmap );

				// Store the target region for picking.
				var region:Rectangle = new Rectangle( offsetX, offsetY, sourceRegion.width, sourceRegion.height );
				regions.push( region );
				_thumbNameForRegion[ region ] = thumbName;

				// Advance target positioning offsets.
				if( offsetX + _cellSize >= _sheetWidth - THUMB_SIZE ) {
					offsetX = 0;
					offsetY += _cellSize;
				}
				else {
					offsetX += _cellSize;
				}
			}

			// Draw sprite into a bitmap data, into a bitmap texture, and register the texture for this sheet.
			var sheetBmd:BitmapData = new BitmapData( _sheetWidth, _sheetHeight, false, 0xFFFFFF );
			sheetBmd.draw( drawSprite );
			registerTextureForSheet( new BitmapTexture( sheetBmd ), sheetIndex );

			// Store the sprite for interaction.
			_interactionRegionsForSheet[ sheetIndex ] = regions;
		}

		private function loadFullImage( fileName:String ):void {
			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}
			_imageLoader = new BitmapLoader();
//			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/paint-packaged-ios/" : "/paint-packaged-desktop/";
			var rootUrl:String = "/book-packaged/";
			_imageLoader.loadAsset( rootUrl + "samples/fullsize/" + fileName, onImageLoaded );
		}

		private function onImageLoaded( bmd:BitmapData ):void {
			fullImagePickedSignal.dispatch( bmd );
		}

		// ---------------------------------------------------------------------
		// Obligatory overrides.
		// ---------------------------------------------------------------------

		override protected function onNonCachedSheetRequested( index:uint ):void {

			// Evaluate thumbnail indices involved.
			var firstThumbIndex:uint = _thumbsPerSheet * index;
			var lastThumbIndex:uint = Math.min( firstThumbIndex + _thumbsPerSheet, _numThumbs ) - 1;

			// Generate sheet.
			generateSheetForIndices( firstThumbIndex, lastThumbIndex, index );
		}

		override public function get numSheets():uint {
			return _numSheets;
		}

		// ---------------------------------------------------------------------
		// Optional overrides.
		// ---------------------------------------------------------------------

		override protected function onClick( sheetIndex:uint, mouseX:Number, mouseY:Number ):void {
//			trace( this, "clicked sheet " + sheetIndex + ", at: " + mouseX + ", " + mouseY );
			// Sweep the interaction regions associated to this sheet and look for a hit.
			var regions:Vector.<Rectangle> = _interactionRegionsForSheet[ sheetIndex ];
			var numRegions:uint = regions.length;
			for( var i:uint = 0; i < numRegions; i++ ) {
				var region:Rectangle = regions[ i ];
				if( region.contains( mouseX, mouseY ) ) {
					loadFullImage( _thumbNameForRegion[ region ] + ".jpg" );
					break;
				}
			}
		}

		override protected function onDispose():void {
			// TODO!!
		}

		override protected function onDisposeSheetAtIndex( index:uint ):void {
//			trace( this, "disposing sheet: " + index );
			// Registered textures are automatically disposed, but you may want to dispose other sheet data here.
			// TODO!!
		}
	}
}
