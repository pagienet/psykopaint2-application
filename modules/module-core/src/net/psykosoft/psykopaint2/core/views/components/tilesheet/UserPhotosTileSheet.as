package net.psykosoft.psykopaint2.core.views.components.tilesheet
{

	import net.psykosoft.psykopaint2.base.utils.IosImagesFetcher;


	public class UserPhotosTileSheet extends TileSheet
	{
		private var _fetcher:IosImagesFetcher;

		public function UserPhotosTileSheet() {
			super();
			_positionManager.closestSnapPointChangedSignal.add( onClosestSnapPointChanged );
		}

		public function fetchPhotos():void {

			// TODO: initialize fetcher


			// TODO: get num tiles and thumb size from ane
			initializeWithProperties( 160, 150 );
			updatePage( 0 );
		}

		private function updatePage( index:uint ):void {
			// TODO: get the necessary items from the ane to fill this page
		}

		private function onClosestSnapPointChanged( snapPointIndex:uint ):void {
			updatePage( snapPointIndex );
		}
	}
}
