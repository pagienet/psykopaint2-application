package net.psykosoft.psykopaint2.base.utils.images
{

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import away3d.tools.utils.TextureUtils;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class BitmapDataUtils
	{
		static public function aspectRatioMatches( map:BitmapData, targetRatio : Number, errorMargin : Number = .007 ) : Boolean
		{
			return Math.abs(map.width/map.height - targetRatio) < errorMargin;
		}

		static public function getLegalBitmapData( map:BitmapData, forceClone:Boolean = false, maxDimension:int = 2048 ):BitmapData {
			if( map.width <= maxDimension && map.height <= maxDimension ) return forceClone ? map.clone() : map;

			var scale:Number = Math.max( maxDimension / map.width, maxDimension / map.height );
			if( map.width * scale > maxDimension || map.height * scale > maxDimension )
				scale = Math.min( maxDimension / map.width, maxDimension / map.height );

			var result:BitmapData = new TrackedBitmapData( map.width * scale, map.height * scale, true, 0 );
			result.draw( map, new Matrix( scale, 0, 0, scale ), null, "normal", null, true );
			return result;
		}

		static public function scaleBitmapData( source:BitmapData, scale:Number ):BitmapData {
			var matrix:Matrix = new Matrix();
			matrix.scale( scale, scale );
			var scaledBmd:BitmapData = new TrackedBitmapData( source.width * scale, source.height * scale, false, 0 );
			scaledBmd.draw( source, matrix );
			return scaledBmd;
		}

		static public function getBitmapDataFromBytes( bytes:ByteArray, width:Number, height:Number, fillWhite : Boolean ):BitmapData {
			bytes.position = 0;

			var bitmapData:BitmapData = new TrackedBitmapData( width, height, fillWhite, 0 );
			var rect : Rectangle = bitmapData.rect;
			var point : Point = new Point();

			bitmapData.setPixels(rect, bytes);

			// undo faulty premultiplication
			if (fillWhite) {
				var tmp:BitmapData = new TrackedBitmapData( width, height, false, 0xffffffff );
				var matrix : Array =
						[	1, 0, 0, -1, 0xff,
							0, 1, 0, -1, 0xff,
							0, 0, 1, -1, 0xff,
							0, 0, 0, 0, 0xff
						];

				tmp.applyFilter(bitmapData, rect, point, new ColorMatrixFilter(matrix));
				// okay... ColorMatrixFilter resolves rgb to alpha 0 to purple... so we need to reset it to white -_-
				tmp.threshold(bitmapData, rect, point, "==", 0, 0xffffffff, 0xff000000, false);
				bitmapData.dispose();
				return tmp;
			}

			return bitmapData;
		}
		
		static public function autoResizePowerOf2(bmData:BitmapData,smoothing:Boolean = true):BitmapData 
		{
			if (TextureUtils.isBitmapDataValid(bmData))
				return bmData;
			
			var max:Number = Math.max(bmData.width, bmData.height);
			max = TextureUtils.getBestPowerOf2(max);
			var mat:Matrix = new Matrix();
			mat.scale(max/bmData.width, max/bmData.height);
			var bmd:BitmapData = new BitmapData(max, max,bmData.transparent,0x00000000);
			bmd.draw(bmData, mat, null, null, null, smoothing);
			return bmd;
		} 
		

		static public function scaleToFit( sourceBmd:BitmapData, size:Number ):BitmapData {
			var wRatio:Number = size / sourceBmd.width;
			var hRatio:Number = size / sourceBmd.height;
			var ratio:Number = Math.max( wRatio, hRatio );
			return BitmapDataUtils.scaleBitmapData( sourceBmd, ratio );
		}
	}
}