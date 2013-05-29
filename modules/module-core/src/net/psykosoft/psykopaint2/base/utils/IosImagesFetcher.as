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
		private var _latestThumbnailRetrieved:uint;
		private var _currentVO:SheetVO;
		private var _sheetVOs:Vector.<SheetVO>;
		private var _initializeCallback:Function;
		private var _extensionInitialized:Boolean;

		private var _imageLoadedSignal:Signal;
		private var _thumbnailsLoadedSignal:Signal;

		private const THUMBS_PER_SHEET:uint = 36;

		public function IosImagesFetcher( thumbSize:Number ) {
			_thumbSize = thumbSize;
			_imageLoadedSignal = new Signal();
			_thumbnailsLoadedSignal = new Signal();
		}

		public function disposeService():void {

			trace( this, "disposing service." );

			_latestThumbnailRetrieved = 0;
			_extensionInitialized = false;

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

		public function loadThumbnails():void {
			if( !_extensionInitialized ) initializeExtension( startLoadingThumbnails );
			else startLoadingThumbnails();
		}

		private function startLoadingThumbnails():void {
			if( !_extensionInitialized ) return;
			_sheetVOs = new Vector.<SheetVO>();
			_extension.addEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			getNextThumbnailSheet();
		}

		private function getNextThumbnailSheet():void {
			if( !_extensionInitialized ) return;
			var base:uint = _latestThumbnailRetrieved;
			if( _latestThumbnailRetrieved + THUMBS_PER_SHEET < _totalItems ) _latestThumbnailRetrieved += THUMBS_PER_SHEET;
			else _latestThumbnailRetrieved = _totalItems - 1;
			trace( this, "getting sprite sheet for thumbnails: " + base + ", " + _latestThumbnailRetrieved );
			_currentVO = _extension.getThumbnailSheetFromIndexToIndex( base, _latestThumbnailRetrieved, _thumbSize );
			_sheetVOs.push( _currentVO );
		}

		private function onSpriteSheetReady( event:UserPhotosExtensionEvent ):void {

			if( !_extensionInitialized ) return;

			// Notify.
			_thumbnailsLoadedSignal.dispatch( _currentVO );

			// Load next sheet.
			if( !( _latestThumbnailRetrieved == _totalItems - 1 ) ) getNextThumbnailSheet();
			else {
				_extension.removeEventListener( UserPhotosExtensionEvent.SPRITE_SHEET_READY, onSpriteSheetReady );
			}
		}

		private function initializeExtension( callback:Function ):void {
			trace( this, "initializing extension." );
			_initializeCallback = callback;
			_extension = new UserPhotosExtension();
			_extension.addEventListener( UserPhotosExtensionEvent.USER_LIBRARY_READY, onUserLibraryReady );
			_extension.initialize();
		}

		private function onUserLibraryReady( event:UserPhotosExtensionEvent ):void {
			trace( this, "extension initialized." );
			_extensionInitialized = true;
			_extension.removeEventListener( UserPhotosExtensionEvent.USER_LIBRARY_READY, onUserLibraryReady );
			_totalItems = _extension.getNumberOfLibraryItems();
			_initializeCallback();
			_initializeCallback = null;
		}

		public function loadFullImage( id:String ):void {
			if( !_extensionInitialized ) return;
			var index:uint = uint( id );
			trace( this, "picking image at: " + index );
			var bmd:BitmapData = _extension.getFullImageAtIndex( index );
			_imageLoadedSignal.dispatch( bmd );
		}

		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}

		public function getThumbnailsLoadedSignal():Signal {
			return _thumbnailsLoadedSignal;
		}
	}
}
