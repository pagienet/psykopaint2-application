package jp.shichiseki.exif
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import jp.shichiseki.exif.IFDSet;
	
	public class ExifUtils
	{
		public static const PORTRAIT:int = 6;
		public static const PORTRAIT_REVERSE:int = 8;
		
		public static const LANDSCAPE:int = 1;
		public static const LANDSCAPE_REVERSE:int = 3;
		
		/**
		 * function figures out the rotation needed so the image
		 * appears in the right view for the user
		 *
		 *
		 * @param ifd attribute in exif belonging to image
		 * @return the angle to rotate an image based on ifd information
		 * @see http://bit.ly/j70E7T
		 */
		
		public static function extractJpegFromLoader(data:ByteArray ):ByteArray
		{
			var sequence:Vector.<uint> = Vector.<uint>([0xff,0xd8,0xff]);
			data.position = 0;
			var sequencePointer:int = 0;
			var found:Boolean = false;
			while ( true )
			{
				if ( data.bytesAvailable == 0 ) break;
				var b:uint = data.readUnsignedByte();
				if ( b == sequence[sequencePointer] )
				{
					sequencePointer++;
					if ( sequencePointer == sequence.length )
					{
						found = true;
						break;
					}
				}
			}
			if ( found )
			{
				var result:ByteArray = new ByteArray();
				result.writeBytes( data, data.position - sequence.length + 2 );
				result.position = 0;
				return result;
			} else {
				return null;
			}
			
		}
		
		public static function getEyeOrientedAngle( set:IFDSet ):int
		{
			var angle:int = 0;
			
			if( set.primary[ "Orientation" ] )
			{
				switch( set.primary[ "Orientation" ] )
				{
					case LANDSCAPE: angle = 0; break;
					case LANDSCAPE_REVERSE: angle = 180; break;
					case PORTRAIT: angle = 90; break;
					case PORTRAIT_REVERSE: angle = -90; break;
				}
			}
			
			return angle;
		}
		
		
		/**
		 * creates a bitmap appealing to the eye, so that based on provided original bitmap and its IFDSet
		 * it's possible to track the orientation and create a transformed bitmap copied from the original.
		 *
		 * @see <a href="http://www.psyked.co.uk/actionscript/rotating-bitmapdata.htm">rotating-bitmapdata.htm</a>
		 * @see  <a href="http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/geom/Matrix.html">matrix documentation</a>
		 *
		 * @param bitmap retrieved after selecting an image from CameraRoll
		 * @param set retrieved after loading the Exif data from selected image
		 * @return a new bitmap in the right angle and same dimensions as the original.
		 *
		 */
		public static function getEyeOrientedBitmapData( map:BitmapData, ifdSet:IFDSet ):BitmapData
		{
			var m:Matrix = new Matrix();
			var orientation:int= ifdSet.primary[ "Orientation" ];
			var bitmapData:BitmapData;
			
			if( orientation == LANDSCAPE )
			{
				bitmapData = map;
			} else if( orientation == LANDSCAPE_REVERSE )
			{
				bitmapData = map.clone();
			}
			else
			{
				bitmapData = new BitmapData( map.height, map.width, true );
			}
			
			m.rotate( getEyeOrientedAngle( ifdSet ) * ( Math.PI / 180 ) );
			
			if( orientation == PORTRAIT_REVERSE )
			{
				m.translate( 0, map.width );
			}
			else
				if( orientation == PORTRAIT )
				{
					m.translate( map.height, 0 );
				}
				else
					if( orientation == LANDSCAPE_REVERSE )
					{
						m.translate( map.width, map.height );
					}
			
			if ( m.a != 1 || m.b != 0 || m.c != 0 || m.d != 1 || m.tx != 0 || m.ty != 0 ) bitmapData.draw( map, m );
			
			return bitmapData;
		}
	}
}