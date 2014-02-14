package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.StrokeAppendVO;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class PyramidMapIntrinsicsStrategy implements  IColorStrategy
	{
		private var _canvasModel : CanvasModel;
		private static var _sourceBitmapData : BitmapData;
		private var tmpRGB:Vector.<Number>;
		private var _colorMatrix:Vector.<Number>;
		private var _colorMatrixBlend:Number;
		public function PyramidMapIntrinsicsStrategy(canvas : CanvasModel)
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
			
			if ( _colorMatrixBlend > 0 && _colorMatrix )
			{
				var c:Vector.<Number> = _colorMatrix;
				var f:Number = _colorMatrixBlend;
				var fi:Number = 1 - f;
				var t0:Number,t1:Number,t2:Number;
				var r1:Number = (t0=tmpRGB[0]) * c[0] + (t1=tmpRGB[1]) * c[1] + (t2=tmpRGB[2]) * c[2] +  c[3];
				var g1:Number = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
				var b1:Number = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
				var r2:Number = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
				var g2:Number = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
				var b2:Number = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
				var l:Number = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
				if ( l > 1 ) l = 1;
				else if ( l < 0 ) l = 0;
				var li:Number = 1 - l;
				tmpRGB[0] = fi * t0 + f * (l*r2 + li*r1);
				tmpRGB[1] = fi * t1 + f * (l*g2 + li*g1);
				tmpRGB[2] = fi * t2 + f * (l*b2 + li*b1);
			}
			
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
		
		
		public function getColors(p:SamplePoint, radius : Number, sampleSize:Number  ) : void
		{
			var target: Vector.<Number> = p.colorsRGBA;
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
				
				if ( _colorMatrixBlend > 0 && _colorMatrix )
				{
					var c:Vector.<Number> = _colorMatrix;
					var f:Number = _colorMatrixBlend;
					var fi:Number = 1 - f;
					var t0:Number,t1:Number,t2:Number;
					var r1:Number = (t0=tmpRGB[0]) * c[0] + (t1=tmpRGB[1]) * c[1] + (t2=tmpRGB[2]) * c[2] +  c[3];
					var g1:Number = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
					var b1:Number = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
					var r2:Number = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
					var g2:Number = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
					var b2:Number = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
					var l:Number = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
					if ( l > 1 ) l = 1;
					else if ( l < 0 ) l = 0;
					var li:Number = 1 - l;
					tmpRGB[0] = fi * t0 + f * (l*r2 + li*r1);
					tmpRGB[1] = fi * t1 + f * (l*g2 + li*g1);
					tmpRGB[2] = fi * t2 + f * (l*b2 + li*b1);
				}
				
				target[j] = tmpRGB[0];
				j++;
				target[j] = tmpRGB[1];
				j++;
				target[j] = tmpRGB[2];
				j+=2;
				//target[j] =  1;
				//j++;
			}
		}
		
		public function getColorsByVO(appendVO:StrokeAppendVO, sampleSize : Number) : void
		{
			var target: Vector.<Number> = appendVO.point.colorsRGBA;
			
			var baseAngle:Number = appendVO.diagonalAngle; 
			//var halfSize : Number = appendVO.size * Math.SQRT1_2;
			var halfSize : Number = appendVO.size * appendVO.diagonalLength * 0.5;//appendVO.size * Math.SQRT1_2;
			
			var angle : Number = appendVO.point.angle;
			var cos1 : Number =   halfSize * Math.cos(  baseAngle + angle);
			var sin1 : Number =   halfSize * Math.sin(  baseAngle + angle);
			var cos2 : Number =   halfSize * Math.cos( -baseAngle + angle);
			var sin2 : Number =   halfSize * Math.sin( -baseAngle + angle);
			
			var px:Number = appendVO.point.x;
			var py:Number = appendVO.point.y;
			
			var ox:Number = appendVO.quadOffsetRatio * (-cos1 - cos2);
			var oy:Number = appendVO.quadOffsetRatio * (-sin1 - sin2);
			
			
			_canvasModel.pyramidMap.getRGB(px - cos1 + ox,py - sin1 + oy,sampleSize,tmpRGB);
			target[0] = tmpRGB[0];
			target[1] = tmpRGB[1];
			target[2] = tmpRGB[2];
			
			_canvasModel.pyramidMap.getRGB(px + cos2 + ox,py + sin2 + oy,sampleSize,tmpRGB);
			target[4] = tmpRGB[0];
			target[5] = tmpRGB[1];
			target[6] = tmpRGB[2];
			
			_canvasModel.pyramidMap.getRGB(px + cos1 + ox,py + sin1 + oy,sampleSize,tmpRGB);
			target[8] = tmpRGB[0];
			target[9] = tmpRGB[1];
			target[10] = tmpRGB[2];
			
			_canvasModel.pyramidMap.getRGB(px - cos2 + ox,py - sin2 + oy,sampleSize,tmpRGB);
			target[12] = tmpRGB[0];
			target[13] = tmpRGB[1];
			target[14] = tmpRGB[2];
			
			if ( _colorMatrixBlend > 0 && _colorMatrix )
			{
				var c:Vector.<Number> = _colorMatrix;
				var f:Number = _colorMatrixBlend;
				var fi:Number = 1 - f;
				var t0:Number,t1:Number,t2:Number;
				var r1:Number = (t0=target[0]) * c[0] + (t1=target[1]) * c[1] + (t2=target[2]) * c[2] +  c[3];
				var g1:Number = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
				var b1:Number = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
				var r2:Number = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
				var g2:Number = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
				var b2:Number = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
				var l:Number = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
				if ( l > 1 ) l = 1;
				else if ( l < 0 ) l = 0;
				var li:Number = 1 - l;
				target[0] = fi * t0 + f * (l*r2 + li*r1);
				target[1] = fi * t1 + f * (l*g2 + li*g1);
				target[2] = fi * t2 + f * (l*b2 + li*b1);
				
				r1 = (t0=target[4]) * c[0] + (t1=target[5]) * c[1] + (t2=target[6]) * c[2] +  c[3];
				g1 = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
				b1 = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
				r2 = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
				g2 = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
				b2 = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
				l = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
				if ( l > 1 ) l = 1;
				else if ( l < 0 ) l = 0;
				li = 1 - l;
				target[4] = fi * t0 + f * (l*r2 + li*r1);
				target[5] = fi * t1 + f * (l*g2 + li*g1);
				target[6] = fi * t2 + f * (l*b2 + li*b1);
				
				r1 = (t0=target[8]) * c[0] + (t1=target[9]) * c[1] + (t2=target[10]) * c[2] +  c[3];
				g1 = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
				b1 = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
				r2 = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
				g2 = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
				b2 = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
				l = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
				if ( l > 1 ) l = 1;
				else if ( l < 0 ) l = 0;
				li = 1 - l;
				target[8] = fi * t0 + f * (l*r2 + li*r1);
				target[9] = fi * t1 + f * (l*g2 + li*g1);
				target[10] = fi * t2 + f * (l*b2 + li*b1);
				
				r1 = (t0=target[12]) * c[0] + (t1=target[13]) * c[1] + (t2=target[14]) * c[2] +  c[3];
				g1 = t0 * c[4] + t1 * c[5] + t2 * c[6] +  c[7];
				b1 = t0 * c[8] + t1 * c[9] + t2 * c[10] +  c[11];
				r2 = t0 * c[12] + t1 * c[13] + t2 * c[14] +  c[15];
				g2 = t0 * c[16] + t1 * c[17] + t2 * c[18] +  c[19];
				b2 = t0 * c[20] + t1 * c[21] + t2 * c[22] +  c[23];
				l = ((0.299 * t0 +  0.587 * t1 +  0.114 * t2) - c[24]) * c[25];
				if ( l > 1 ) l = 1;
				else if ( l < 0 ) l = 0;
				li = 1 - l;
				target[12] = fi * t0 + f * (l*r2 + li*r1);
				target[13] = fi * t1 + f * (l*g2 + li*g1);
				target[14] = fi * t2 + f * (l*b2 + li*b1);
			}
		}
		
		public function getSignificantColorPalette( colorCount:int ):Vector.<uint>
		{
			var result:Vector.<uint> = new Vector.<uint>(colorCount,false);
			return result;
		}
		
		public function setColorMatrix( matrix:Vector.<Number>, blendFactor:Number ):void
		{
			_colorMatrix = matrix;
			_colorMatrixBlend = blendFactor;
		}
	}
}
