package net.psykosoft.psykopaint2.book.views.book.content
{

	import away3d.core.managers.Stage3DProxy;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class TestBookDataProvider extends BookDataProviderBase
	{
		public function TestBookDataProvider( proxy:Stage3DProxy ) {
			super( proxy );
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

		override protected function onSheetAtIndexNotNeeded( index:uint ):void {
			// If desired, disposed data here.
			// You can dispose the texture too, using:
//			disposeSheetTextureAtIndex( index );
		}

		override protected function onClick( sheetIndex:uint, localX:Number, localY:Number ):void {
			trace( this, "clicked sheet " + sheetIndex + ", at: " + localX + ", " + localY );
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function generateTextureWithNumber( value:uint ):BitmapTexture {
			trace( this, "created texture for index: " + value );
			var bmd:BitmapData = new TrackedBitmapData( _sheetWidth, _sheetHeight, false, 0xFF0000 );
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
