package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.textures.BitmapTexture;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.utils.io.IosUserImagesFetcher;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class UserPhotosBookDataProvider extends BookDataProviderBase
	{
		private var _fetcher:IosUserImagesFetcher;
		private var _thumbsPerSheet:uint;
		private var _numRows:uint;
		private var _numColumns:uint;
		private var _cellSize:uint;
		private var _numThumbs:uint;
		private var _numSheets:uint;
		private var _interactionRegionsForSheet:Dictionary;
		private var _thumbIndexForRegion:Dictionary;
		private var _thumbSize:uint;
		private var _thumbQueue:Vector.<Object>;

		public var readySignal:Signal;
		public var fullImagePickedSignal:Signal;

		private const THUMB_GAP:uint = 20;

		public function UserPhotosBookDataProvider() {
			super();
			readySignal = new Signal();
			fullImagePickedSignal = new Signal();
			_interactionRegionsForSheet = new Dictionary();
			_thumbIndexForRegion = new Dictionary();
			_thumbQueue = new Vector.<Object>();
			initializeFetcher();
		}

		override public function dispose():void {

			// TODO...

			super.dispose();
		}

		private function initializeFetcher():void {
			_fetcher = new IosUserImagesFetcher( CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 150 : 75 );
			_fetcher.thumbSheetLoadedSignal.add( onThumbSheetLoaded );
			_fetcher.extensionInitializedSignal.addOnce( onFetcherReady );
			_fetcher.fullImageLoadedSignal.add( onFullImageLoaded );
			_fetcher.initializeExtension();
		}

		private function onFetcherReady():void {
			evaluateFigures();
			readySignal.dispatch();
		}

		private function evaluateFigures():void {
			_thumbSize = _fetcher.thumbSize;
			_cellSize = _thumbSize + THUMB_GAP;
			_numColumns = Math.floor( _sheetWidth / _cellSize );
			_numRows = Math.floor( _sheetHeight / _cellSize );
			_thumbsPerSheet = _numColumns * _numRows;
			_numThumbs = _fetcher.totalItems;
			_numSheets = Math.ceil( _numThumbs / _thumbsPerSheet );
			if( _numSheets % 2 != 0 ) _numSheets++; // Need to provide an even number of sheets for the book.
			trace( this, "num thumbs: " + _numThumbs );
			trace( this, "num columns: " + _numColumns );
			trace( this, "num rows: " + _numRows );
			trace( this, "num per sheet: " + _thumbsPerSheet );
			trace( this, "num sheets: " + _numSheets );
		}

		private function generateSheetForIndices( firstThumbIndex:uint, lastThumbIndex:uint, sheetIndex:uint, sourceBmd:BitmapData, sourceSize:uint ):void {

			trace( this, "generating sheet " + sheetIndex + " for thumb indices from " + firstThumbIndex + ", " + lastThumbIndex + " -----------------------" );

			// Produces a sprite containing the thumbnails as bitmaps.
			var i:uint;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			var drawSprite:Sprite = new Sprite();
			var sourceRegion:Rectangle = new Rectangle( 0, 0, _thumbSize, _thumbSize );
			var interactionRegions:Vector.<Rectangle> = new Vector.<Rectangle>();
			for( i = firstThumbIndex; i < lastThumbIndex; i++ ) {

				// Produce a bitmap that wraps the thumbnail.
				var thumbBitmap:Bitmap = new Bitmap( sourceBmd );
				thumbBitmap.x = offsetX;
				thumbBitmap.y = offsetY;
				thumbBitmap.scrollRect = sourceRegion;
				drawSprite.addChild( thumbBitmap );

				// Store the target region for picking.
				var interactionRegion:Rectangle = new Rectangle( offsetX, offsetY, _thumbSize, _thumbSize );
				interactionRegions.push( interactionRegion );
				_thumbIndexForRegion[ interactionRegion ] = i;

				// Advance source positioning offsets.
				if( sourceRegion.x + _thumbSize >= sourceSize ) {
					sourceRegion.x = 0;
					sourceRegion.y += _thumbSize;
				}
				else {
					sourceRegion.x += _thumbSize;
				}

				// Advance target positioning offsets.
				if( offsetX + _cellSize >= _sheetWidth ) {
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
			_interactionRegionsForSheet[ sheetIndex ] = interactionRegions;
		}

		private function onFullImageLoaded( bmd:BitmapData ):void {
			fullImagePickedSignal.dispatch( bmd );
		}

		private function queueThumbSheet( fromIndex:uint, toIndex:uint ):void {
			trace( this, "fetcher busy, queueing sheet - from index: " + fromIndex + ", toIndex: " + toIndex );
			_thumbQueue.push( { fromIndex: fromIndex, toIndex: toIndex } );
		}

		private function fetchThumbSheet( fromIndex:uint, toIndex:uint ):void {
			trace( this, "getting sheet from fetcher - from index: " + fromIndex + ", toIndex: " + toIndex );
			_fetcher.getThumbnailSheet( fromIndex, toIndex );
		}

		// ---------------------------------------------------------------------
		// Obligatory overrides.
		// ---------------------------------------------------------------------

		override protected function onNonCachedSheetRequested( index:uint ):void {

			// Evaluate thumbnail indices involved.
			var firstThumbIndex:uint = _thumbsPerSheet * index;
			if( firstThumbIndex >= _numThumbs - 1 ) return;
			var lastThumbIndex:uint = Math.min( firstThumbIndex + _thumbsPerSheet, _numThumbs ) - 1;
			trace( this, "requested sheet: " + index + ", from index: " + firstThumbIndex + " to index: " + lastThumbIndex );

			// Request sheet.
			if( _fetcher.busy ) queueThumbSheet( firstThumbIndex, lastThumbIndex );
			else fetchThumbSheet( firstThumbIndex, lastThumbIndex );
		}

		private function onThumbSheetLoaded( sheetData:SheetVO ):void {

			// Generate book sheet from thumb sheet.
			var firstThumbIndex:uint = sheetData.baseItemIndex;
			var lastThumbIndex:uint = firstThumbIndex + sheetData.numberOfItems;
			var sheetIndex:uint = sheetData.baseItemIndex / _thumbsPerSheet;
			trace( this, "retrieved thumb sheet: " + sheetIndex + ", from index: " + firstThumbIndex + ", to index: " + lastThumbIndex );
			generateSheetForIndices( firstThumbIndex, lastThumbIndex, sheetIndex, sheetData.bmd, sheetData.sheetSize );

			// Anything in queue?
			if( _thumbQueue.length > 0 ) {
				var lastIndex:uint = _thumbQueue.length - 1;
				var indicesObject:Object = _thumbQueue[ lastIndex ];
				trace( this, "dealing with next list in queue" );
				fetchThumbSheet( indicesObject.fromIndex, indicesObject.toIndex );
				_thumbQueue.splice( lastIndex, 1 );
			}
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
					_fetcher.loadFullImage( _thumbIndexForRegion[ region ] );
					break;
				}
			}
		}

		override protected function onDispose():void {
			_fetcher.dispose();
		}

		override protected function onSheetAtIndexNotNeeded( index:uint ):void {
			// If desired, disposed data here.
			// You can dispose the texture too, using:
//			disposeSheetTextureAtIndex( index );
		}
	}
}
