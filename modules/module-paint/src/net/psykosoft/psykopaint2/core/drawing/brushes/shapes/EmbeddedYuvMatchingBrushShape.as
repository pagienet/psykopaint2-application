package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	
	public class EmbeddedYuvMatchingBrushShape extends EmbeddedBrushShape
	{
		// this contains the average yuv values for each cell. Precalculated by the Brushset creation tool
		protected var uvColorData:Vector.<int>;
		
		public function EmbeddedYuvMatchingBrushShape(context3D : Context3D, id : String, colorAsset : Class, normalSpecularAsset : Class, size:int, cols:int = 1, rows:int = 1)
		{
			super(context3D, id, colorAsset, normalSpecularAsset, size, cols, rows);
		}

		override public function getClosestColorMatchYUV( color:Vector.<Number>, targetRect:Rectangle, mismatchProbability:Number = 0, YUVWeights:Vector.<Number> = null):void
		{
			if ( YUVWeights == null ) YUVWeights = _YUVWeights;
			var y:int = 76.245 * color[0] + 149.685 * color[1] + 29.07 * color[2];
			var u:int = -43.0287 * color[0] -84.4713 * color[1] + 127.5 * color[2] + 128.5;
			var v:int = 127.5 * color[0] -106.76595 * color[1] -20.73405 * color[2] + 128.5;
			var ud:int, vd:int, yd:int, sd:int;
			
			var j:int = int(Math.random() * _variationFactors[0] * _variationFactors[1]) * 3;
			var bestSd:int = YUVWeights[0] * (yd = y - uvColorData[j]) * vd + YUVWeights[1] * (ud = u - uvColorData[j+1]) * ud + YUVWeights[2] * (vd = v - uvColorData[j+2]) * vd ;
			var bestJ:int = j;
			for ( var i:int = 3; i < uvColorData.length; i+=3 )
			{
				j = ( j + 3 ) % uvColorData.length;
				sd = YUVWeights[0] * (yd = y - uvColorData[j]) * yd + 
					 YUVWeights[1] * (ud = u - uvColorData[j+1]) * ud + 
					 YUVWeights[2] * (vd = v - uvColorData[j+2]) * vd;
				
				var check:Boolean = Math.random() < mismatchProbability;
				if ( (!check  && sd < bestSd) || check   )
				{
					bestSd = sd;
					bestJ = j;
				}
			}
			
			bestJ /= 3;
			targetRect.x = _variationFactors[2] * (bestJ % _variationFactors[0]);
			targetRect.y = _variationFactors[3] * int(bestJ / _variationFactors[0]);
			targetRect.width  = _variationFactors[2];
			targetRect.height = _variationFactors[3];
		}

	}
}
