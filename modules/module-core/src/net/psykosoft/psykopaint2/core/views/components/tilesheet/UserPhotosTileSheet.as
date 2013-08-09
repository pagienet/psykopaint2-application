package net.psykosoft.psykopaint2.core.views.components.tilesheet
{

	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.utils.io.IosUserImagesFetcher;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	public class UserPhotosTileSheet extends TileSheet
	{
		private var _fetcher:IosUserImagesFetcher;
		private var _maxPageFetched:uint;

		public var fullImageFetchedSignal:Signal;

		public function UserPhotosTileSheet() {
			super();
			fullImageFetchedSignal = new Signal();
		}

		override public function dispose():void {
			_fetcher.dispose();
		}

		public function fetchPhotos():void {
			_maxPageFetched = 0;
			_fetcher = new IosUserImagesFetcher( CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 150 : 75 );
			_fetcher.thumbSheetLoadedSignal.add( onThumbnailsLoaded );
			_fetcher.extensionInitializedSignal.addOnce( onExtensionReady );
			_fetcher.fullImageLoadedSignal.add( onFullImageLoaded );
			_fetcher.initializeExtension();
		}

		private function onExtensionReady():void {
			// Initialize grid.
			initializeWithProperties( _fetcher.totalItems, _fetcher.thumbSize );
			// First data fetch.
			fetchPage( 0 );
			setTimeout( function():void {
				fetchPage( 1 );
			}, 250 );
		}

		private function fetchPage( pageIndex:uint ):void {
			var baseIndex:uint = pageIndex * numberOfItemsPerPage;
			_fetcher.getThumbnailSheet( baseIndex, baseIndex + numberOfItemsPerPage );
			if( pageIndex > _maxPageFetched ) _maxPageFetched = pageIndex;
		}

		private function onThumbnailsLoaded( sheet:SheetVO ):void {
			// Populate the appropriate tiles with the incoming thumbnails.
			var index:uint;
			var sx:Number = 0;
			var sy:Number = 0;
			for( var i:uint; i < sheet.numberOfItems; ++i ) {
				index = sheet.baseItemIndex + i;
				setTileContentFromSpriteSheet( sheet.bmd, sx, sy, index );
				// Advance in sheet space.
				sx += _tileSize;
				if( sx + _tileSize > sheet.sheetSize ) {
					sx = 0;
					sy += _tileSize;
				}
			}
		}

		override protected function onClosestSnapPointChanged( snapPointIndex:uint ):void {
			super.onClosestSnapPointChanged( snapPointIndex );
			if( _activePageIndex == _maxPageFetched ) fetchPage( _activePageIndex + 1 );
		}

		override protected function onTileClicked( tileIndex:uint ):void {
			_fetcher.loadFullImage( String( tileIndex ) );
		}

		private function onFullImageLoaded( bmd:BitmapData ):void {
			fullImageFetchedSignal.dispatch( bmd );
		}
	}
}
