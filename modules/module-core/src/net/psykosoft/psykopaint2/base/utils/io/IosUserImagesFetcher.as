package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.BitmapData;

	import net.psykosoft.photos.UserPhotosExtension;
	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.photos.events.UserPhotosExtensionEvent;

	import org.osflash.signals.Signal;

	public class IosUserImagesFetcher
	{
		private var _extension:UserPhotosExtension;
		private var _totalItems:uint;
		private var _thumbSize:uint;
		private var _currentVO:SheetVO;
		private var _sheetVOs:Vector.<SheetVO>;
		private var _busy:Boolean;

		public var fullImageLoadedSignal:Signal;
		public var thumbSheetLoadedSignal:Signal;
		public var extensionInitializedSignal:Signal;

		public function IosUserImagesFetcher( thumbSize:Number ) {
			_thumbSize = thumbSize;
			fullImageLoadedSignal = new Signal();
			thumbSheetLoadedSignal = new Signal();
			extensionInitializedSignal = new Signal();
			_sheetVOs = new Vector.<SheetVO>();
		}

		public function dispose():void {

			trace( this, "disposing" );

			// Dispose of all bmds in flash.
			for( var i:uint = 0; i < _sheetVOs.length; ++i ) {
				var vo:SheetVO = _sheetVOs[ i ];
				vo.bmd.dispose();
				vo = null;
			}
			_sheetVOs = null;

			// Clean up extension.
			_extension.releaseLibraryItems();
			_extension = null;
		}

		public function initializeExtension():void {
			trace( this, "initializing extension..." );
			_extension = new UserPhotosExtension();
			_extension.addEventListener( UserPhotosExtensionEvent.USER_LIBRARY_READY, onUserLibraryReady );
			_extension.initialize();
		}

		private function onUserLibraryReady( event:UserPhotosExtensionEvent ):void {
			trace( this, "extension initialized." );
			_extension.removeEventListener( UserPhotosExtensionEvent.USER_LIBRARY_READY, onUserLibraryReady );
			_totalItems = _extension.getNumberOfLibraryItems();
			extensionInitializedSignal.dispatch();
		}

		public function getThumbnailSheet( fromIndex:uint, toIndex:uint ):SheetVO {
			if( _busy ) {
				throw new Error( "IosUserImagesFetcher - please do not request thumbs while the fetcher is busy fetching a set of thumbs already." );
			}
			_busy = true;
			_extension.addEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			_currentVO = _extension.getThumbnailSheetFromIndexToIndex( fromIndex, toIndex, _thumbSize );
			_sheetVOs.push( _currentVO );
			return _currentVO;
		}

		private function onSpriteSheetReady( event:UserPhotosExtensionEvent ):void {
			_busy = false;
			_extension.removeEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			thumbSheetLoadedSignal.dispatch( _currentVO );
		}

		public function loadFullImage( id:String ):void {
			var index:uint = uint( id );
			trace( this, "loading full image image at: " + index );
			var bmd:BitmapData = _extension.getFullImageAtIndex( index );
			fullImageLoadedSignal.dispatch( bmd );
		}

		public function get totalItems():uint {
			return _totalItems;
		}

		public function get thumbSize():uint {
			return _thumbSize;
		}

		public function get busy():Boolean {
			return _busy;
		}
	}
}
