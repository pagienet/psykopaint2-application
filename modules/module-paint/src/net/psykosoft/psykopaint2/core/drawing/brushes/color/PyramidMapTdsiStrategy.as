package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class PyramidMapTdsiStrategy implements  IColorStrategy
	{
		private var _canvasModel : CanvasModel;
		private static var _sourceBitmapData : BitmapData;
		//private var _colorBlendFactor : Number = .65;
		//private var _brushAlpha : Number = .1;
		private var tmpRGB:Vector.<Number>;
		//private var _currentR : Number = 0;
		//private var _currentG : Number = 0;
		//private var _currentB : Number = 0;

		public function PyramidMapTdsiStrategy(canvas : CanvasModel)
		{
			_canvasModel = canvas;
			tmpRGB = new Vector.<Number>(3,true);
		}
		
		/*
		public function setBlendFactors(colorBlendFactor : Number, alphaBlendFactor : Number) : void
		{
			if (colorBlendFactor < 0) colorBlendFactor = 0;
			else if (colorBlendFactor > 1) colorBlendFactor = 1;
			if (alphaBlendFactor < 0) alphaBlendFactor = 0;
			else if (alphaBlendFactor > 1) alphaBlendFactor = 1;
			_colorBlendFactor = colorBlendFactor;
			_brushAlpha = alphaBlendFactor;
		}
		*/

		public function getColor(x : Number, y : Number, size : Number, target : Vector.<Number>, targetIndexMask:int = 15) : void
		{
			if ( (targetIndexMask & 0xf) == 0 ) return;
			var index:int = (targetIndexMask & 1) == 1 ? 0 : (targetIndexMask & 2) == 2 ? 4 : (targetIndexMask & 4) == 4 ? 8 : (targetIndexMask & 8) == 8 ? 12 : -1;
			_canvasModel.pyramidMap.getRGB(x,y,size,tmpRGB );
			
			/*
			var t1:Number = ( target[index] 	   += (tmpRGB[0] * _brushAlpha - target[index] )	    * _colorBlendFactor );
			var t2:Number = ( target[int(index+1)] += (tmpRGB[1] * _brushAlpha - target[int(index+1)] ) * _colorBlendFactor );
			var t3:Number = ( target[int(index+2)] += (tmpRGB[2] * _brushAlpha - target[int(index+2)] ) * _colorBlendFactor );
			var t4:Number = ( target[int(index+3)] += (_brushAlpha - target[int(index+3)]) * _colorBlendFactor );
			*/
			var t1:Number = target[index] 	     = tmpRGB[0];
			var t2:Number = target[int(index+1)] = tmpRGB[1]; 
			var t3:Number = target[int(index+2)] = tmpRGB[2];
			
			if ( (targetIndexMask & 2) == 2 && index != 4)
			{
				target[4] = t1;
				target[5] = t2;
				target[6] = t3;
			}
			if ( (targetIndexMask & 4) == 4 && index != 8)
			{
				target[8]  = t1;
				target[9]  = t2;
				target[10] = t3;
			}
			if ( (targetIndexMask & 8) == 8 && index != 12)
			{
				target[12] = t1;
				target[13] = t2;
				target[14] = t3;
			}
		}
		
		
		public function getColors(p:SamplePoint, radius : Number, sampleSize:Number, target : Vector.<Number> ) : void
		{
			var angle: Number = Math.PI *0.5;
			var baseAngle:Number = 1.25 * Math.PI;
			//1,0,-1,0
			//0,1,0,-1
			var j:int = 0;
			for ( var i:int = 0; i < 4; i++ )
			{
				var px:Number = p.x + radius * Math.cos( baseAngle + i * angle + p.angle );
				var py:Number = p.y + radius * Math.sin( baseAngle + i * angle + p.angle );
				_canvasModel.pyramidMap.getRGB(px,py,sampleSize,tmpRGB);
				/*
				target[j] += (tmpRGB[0] * _brushAlpha - target[j]) * _colorBlendFactor;
				j++;
				target[j] += (tmpRGB[1] * _brushAlpha - target[j]) * _colorBlendFactor;
				j++;
				target[j] += (tmpRGB[2] * _brushAlpha - target[j]) * _colorBlendFactor;
				j++;
				target[j] +=  (_brushAlpha - target[j] ) * _colorBlendFactor;
				j++;
				*/
				target[j] = tmpRGB[0];
				j++;
				target[j] = tmpRGB[1];
				j++;
				target[j] = tmpRGB[2];
				j++;
				target[j] =  1;
				j++;
			}
		}
/*
		private function updateColor(x : Number, y : Number, size : Number) : void
		{
			var channelScale : Number = 1/0xff;
			var c : uint = _colorLookupMap.getPixel32(x, y, size);
			var r : Number = ((c >> 16) & 0xff) * channelScale;
			var g : Number = ((c >> 8) & 0xff) * channelScale;
			var b : Number = (c & 0xff) * channelScale;

			_currentR += (r - _currentR) * _colorBlendFactor;
			_currentG += (g - _currentG) * _colorBlendFactor;
			_currentB += (b - _currentB) * _colorBlendFactor;
		
		}
*/
	}
}
