package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.errors.AbstractMethodError;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class BookDataProviderBase
	{
		private var _activeSheetIndices:Vector.<uint>;
		private var _textureDictionary:Dictionary;
		private var _defaultTexture:BitmapTexture;

		protected var _sheetWidth:uint;
		protected var _sheetHeight:uint;

		public var textureReadySignal:Signal;

		public function BookDataProviderBase() {
			super();
			textureReadySignal = new Signal();
			_textureDictionary = new Dictionary();
			_activeSheetIndices = new Vector.<uint>();
		}

		public function setSheetDimensions( pageWidth:Number, pageHeight:Number ):void {
			_sheetWidth = pageWidth;
			_sheetHeight = pageHeight;
		}

		public function getTextureForSheet( index:uint ):BitmapTexture {
			_activeSheetIndices.push( index );
			var cachedTexture:BitmapTexture = _textureDictionary[ index ];
			if( cachedTexture ) {
				return cachedTexture;
			}
			requestTextureForSheet( index );
			return null;
		}

		public function prepareToDisposeInactiveSheets():void {
			_activeSheetIndices = new Vector.<uint>();
		}

		public function disposeInactiveSheets():void {
			var i:uint;
			var len:uint = numSheets;
			for( i = 0; i < len; i++ ) {
				if( _activeSheetIndices.indexOf( i ) == -1 ) {
					onSheetAtIndexNotNeeded( i );
				}
			}
		}

		public function dispose():void {
			if( _defaultTexture ) {
				_defaultTexture.dispose();
			}
			for each( var texture:BitmapTexture in _textureDictionary ) {
				texture.dispose();
			}
			onDispose();
		}

		public function get defaultTexture():BitmapTexture {
			if( !_defaultTexture ) _defaultTexture = new BitmapTexture( new BitmapData( _sheetWidth, _sheetHeight, false, 0xCCCCCC ) );
			return _defaultTexture;
		}

		public function notifyClickAt( sheetIndex:uint, mouseX:Number, mouseY:Number ):void {
			onClick( sheetIndex, mouseX, mouseY );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function requestTextureForSheet( index:uint ):void {
			_activeSheetIndices.push( index );
			onNonCachedSheetRequested( index );
		}

		protected function disposeSheetTextureAtIndex( index:uint ):void {
			var texture:BitmapTexture = _textureDictionary[ index ];
			if( texture ) {
				trace( this, "disposing sheet: " + index );
				texture.dispose();
				_textureDictionary[ index ] = null;
			}
		}

		protected function registerTextureForSheet( texture:BitmapTexture, index:uint ):void {
			_textureDictionary[ index ] = texture;
			textureReadySignal.dispatch( index, texture );
		}

		// ---------------------------------------------------------------------
		// Obligatory overrides.
		// ---------------------------------------------------------------------

		protected function onNonCachedSheetRequested( index:uint ):void {
			throw new AbstractMethodError();
		}

		public function get numSheets():uint {
			throw new AbstractMethodError();
		}

		// ---------------------------------------------------------------------
		// Optional overrides.
		// ---------------------------------------------------------------------

		protected function onClick( sheetIndex:uint, mouseX:Number, mouseY:Number ):void {
			// Optional.
		}

		protected function onDispose():void {
			// Optional.
		}

		protected function onSheetAtIndexNotNeeded( index:uint ):void {
			// Optional.
		}
	}
}
