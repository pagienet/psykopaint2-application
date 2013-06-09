package net.psykosoft.psykopaint2.base.utils
{

	import flash.display.BitmapData;

	import net.psykosoft.photos.UserPhotosExtension;
	import net.psykosoft.photos.data.SheetVO;
	import net.psykosoft.photos.events.UserPhotosExtensionEvent;

	import org.osflash.signals.Signal;

	public class IosImagesFetcher
	{
		private var _extension:UserPhotosExtension;
		private var _totalItems:uint;
		private var _thumbSize:uint;
		private var _currentVO:SheetVO;
		private var _sheetVOs:Vector.<SheetVO>;

		public var imageLoadedSignal:Signal;
		public var thumbnailsLoadedSignal:Signal;
		public var extensionInitializedSignal:Signal;

		public function IosImagesFetcher( thumbSize:Number ) {
			_thumbSize = thumbSize;
			imageLoadedSignal = new Signal();
			thumbnailsLoadedSignal = new Signal();
			extensionInitializedSignal = new Signal();
			_sheetVOs = new Vector.<SheetVO>();
		}

		public function dispose():void {

			trace( this, "disposing service." );

			// Dispose of all bmds in flash.
			for( var i:uint = 0; i < _sheetVOs.length; ++i ) {
				var vo:SheetVO = _sheetVOs[ i ];
				vo.bmd.dispose();
				vo = null;
			}
			_sheetVOs = null;

			_sheetVOs = new Vector.<SheetVO>();

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
			_extension.addEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			_currentVO = _extension.getThumbnailSheetFromIndexToIndex( fromIndex, toIndex, _thumbSize );
			_sheetVOs.push( _currentVO );
			return _currentVO;
		}

		private function onSpriteSheetReady( event:UserPhotosExtensionEvent ):void {
			_extension.removeEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			thumbnailsLoadedSignal.dispatch( _currentVO );
		}

		public function loadFullImage( id:String ):void {
			var index:uint = uint( id );
			trace( this, "loading full image image at: " + index );
			var bmd:BitmapData = _extension.getFullImageAtIndex( index );
			imageLoadedSignal.dispatch( bmd );
		}

		public function get totalItems():uint {
			return _totalItems;
		}

		public function get thumbSize():uint {
			return _thumbSize;
		}
	}
}
