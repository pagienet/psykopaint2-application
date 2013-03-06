package net.psykosoft.psykopaint2.app.utils
{

	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class TextureUtil
	{
		public static function ensurePowerOf2( bitmapData:BitmapData ):BitmapData {

			var origWidth:int = bitmapData.width;
			var origHeight:int = bitmapData.height;
//			trace( "ensurePowerOf2 - original: " + origWidth + ", " + origHeight );
			var legalWidth:int = getNextPowerOfTwo( origWidth );
			var legalHeight:int = getNextPowerOfTwo( origHeight );
//			trace( "ensurePowerOf2 - altered: " + legalWidth + ", " + legalHeight );

			if( legalWidth > origWidth || legalHeight > origHeight ) {
				var modifiedBmd:BitmapData = new BitmapData( legalWidth, legalHeight, false, 0 );
				var transform:Matrix = new Matrix();
				transform.translate(
					( legalWidth - origWidth ) / 2,
					( legalHeight - origHeight ) / 2
				);
				modifiedBmd.draw( bitmapData, transform );
				bitmapData = modifiedBmd;
			}

			return bitmapData;
		}

		private static function getNextPowerOfTwo( number:int ):int {
			if( number > 0 && (number & (number - 1)) == 0 ) // see: http://goo.gl/D9kPj
				return number;
			else {
				var result:int = 1;
				while( result < number ) result <<= 1;
				return result;
			}
		}
	}
}
