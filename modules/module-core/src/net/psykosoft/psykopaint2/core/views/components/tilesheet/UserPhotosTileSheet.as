package net.psykosoft.psykopaint2.core.views.components.tilesheet
{

	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.psykopaint2.base.utils.IosImagesFetcher;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	public class UserPhotosTileSheet extends TileSheet
	{
		private var _fetcher:IosImagesFetcher;
		private var _activePageIndex:uint;

		public function UserPhotosTileSheet() {
			super();
			_positionManager.closestSnapPointChangedSignal.add( onClosestSnapPointChanged );
		}

		public function dispose():void {
			// TODO
			// TODO: dispose fetcher
		}

		public function fetchPhotos():void {
			_fetcher = new IosImagesFetcher( CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 150 : 75 );
			_fetcher.thumbnailsLoadedSignal.add( onThumbnailsLoaded );
			_fetcher.extensionInitializedSignal.addOnce( onExtensionReady );
			_fetcher.initializeExtension();
		}

		private function onExtensionReady():void {
			// Initialize grid.
			trace( this, "user library ready, num items: " + _fetcher.totalItems );
			initializeWithProperties( _fetcher.totalItems, _fetcher.thumbSize );
			// First data fetch.
			updatePage( 0 );
		}

		private function updatePage( index:uint ):void {
			// Calculate what thumbnails to fetch.
			// TODO
			// Go get them.
			_fetcher.getThumbnailSheet( 0, 36 );
		}

		private function onThumbnailsLoaded( sheet:SheetVO ):void {
			trace( this, "onThumbnailsLoaded --------------------" );
			trace( "items per component page: " + numberOfItemsPerPage );
			var index:uint;
			var sx:Number = 0;
			var sy:Number = 0;
			for( var i:uint; i < sheet.numberOfItems; ++i ) {
				index = sheet.baseItemIndex + i;
				setTileContentFromSpriteSheet( sheet.bmd, sx, sy, _activePageIndex * numberOfItemsPerPage + i );
				// Advance in sheet space.
				if( sx + _tileSize > sheet.sheetSize ) {
					sx = 0;
					sy += _tileSize;
				}
			}
		}

		private function onClosestSnapPointChanged( snapPointIndex:uint ):void {
			_activePageIndex = snapPointIndex;
			updatePage( snapPointIndex );
		}
	}
}
