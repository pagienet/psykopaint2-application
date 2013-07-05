package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	public class NumericBookDataProvider extends BookDataProviderBase
	{
		public function NumericBookDataProvider() {
			super();
		}

		// ---------------------------------------------------------------------
		// Obligatory overrides.
		// ---------------------------------------------------------------------

		override protected function onNonCachedSheetRequested( index:uint ):void {
			// Simulate async texture creation.
			setTimeout( function():void {
				registerTextureForSheet( generateTextureWithNumber( index ), index );
			}, Math.floor( 1000 * Math.random() ) );
		}

		override public function get numSheets():uint {
			return 12;
		}

		// ---------------------------------------------------------------------
		// Optional overrides.
		// ---------------------------------------------------------------------

		override protected function onDisposeSheetAtIndex( index:uint ):void {
//			trace( this, "disposing sheet: " + index );
			// Registered textures are automatically disposed, but you may want to dispose other sheet data here.
		}

		override protected function onClick( sheetIndex:uint, localX:Number, localY:Number ):void {
			trace( this, "clicked sheet " + sheetIndex + ", at: " + localX + ", " + localY );
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function generateTextureWithNumber( value:uint ):BitmapTexture {
			trace( this, "created texture for index: " + value );
			var bmd:BitmapData = new BitmapData( _sheetWidth, _sheetHeight, false, 0xFF0000 );
			printNumberOnBmd( value, bmd );
			return new BitmapTexture( bmd );
		}

		private function printNumberOnBmd( num:Number, bmd:BitmapData ):void {
			var tf:TextField = new TextField();
			var format:TextFormat = tf.defaultTextFormat;
			format.size = 120;
			tf.defaultTextFormat = format;
			tf.text = String( num );
			tf.width += tf.textWidth * 1.1;
			tf.height += tf.textHeight * 1.1;
			bmd.draw( tf );
		}
	}
}
