package net.psykosoft.psykopaint2.core.drawing.colortransfer
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Histogram
	{
		
		public static const THRESHOLD_ENTROPY:String      = "THE";
		public static const THRESHOLD_MOMENT:String       = "THM";
		public static const THRESHOLD_DISCRIMINANT:String = "THD";
		public static const THRESHOLD_OTSU:String         = "THO";
		public static const THRESHOLD_VALUE:String        = "THF";
		
		public static const COMP_CORRELATION:String      = "COR";
		public static const COMP_CHI_SQUARE:String       = "CHI";
		public static const COMP_INTERSECT:String        = "INT";
		public static const COMP_BHATTACHARYYA:String    = "BAT";
		
		private var __data:Vector.<Number>;
		private var __probabilities:Vector.<Number>;
		private var __blank:Vector.<Number>;
		
		private var __total:Number;
		private var __dirty:Boolean;
		private var __median:int;
		private var __size:int;
		private var __map:BitmapData;
		private var __maxData:Number;
		private var __minProbability:Number;
		private var __maxProbability:Number;
		
		private var __coherence:Number;
		
		private var __unnormalizedVariance:Number;;
		private var  __variance:Number;
		private var __standardDeviation:Number;
		private var __skewness:Number;
		private var __kurtosis:Number;
		private var __errorOnAverage:Number;
		private var __moments:Vector.<Number>;
		
		public static function fromVector( data:Vector.<Number> ):Histogram
		{
			var h:Histogram = new Histogram( data.length );
			for ( var i:int = 0; i < data.length; i++ )
			{
				h.setSlot(i,data[i]);
			}
			return h;
		}
		
		function Histogram( size:int )
		{
			__size = size;
			__data = new Vector.<Number>( size, true );
			__probabilities = new Vector.<Number>( size, true );
			__blank = new Vector.<Number>( size, true );
			for ( var i:int = 0; i < size; i++ )
			{
				__blank[i] = 0;
			}
			__moments = new Vector.<Number>(5,true);
			__moments[0] = 0;
			__moments[1] = 0;
			__moments[2] = 0;
			__moments[3] = 0;
			__moments[4] = 0;
			clear();
		}
		
		public function clear():void
		{
			__data = __blank.concat();
			__probabilities = __blank.concat();
			
			__total = 0;
			__maxData = 0;
			
			__dirty = true;
		}
		
		public function add( slot:int ):void
		{
			__data[slot]++;
			
			var n:Number = __moments[0];
			var n1:Number = n + 1;
			var n2:Number = n * n;
			var delta:Number = (__moments[1] - slot) / n1;
			var d2:Number = delta * delta;
			var d3:Number = delta * d2;
			var r1:Number = n / n1;
			
			__moments[4] += 4 * delta * __moments[3] + 6 * d2 * __moments[2] + (1 + n * n2) * d2 * d2;
			__moments[4] *= r1;
			__moments[3] += 3 * delta * __moments[2] + (1 - n2) * d3;
			__moments[3] *= r1;
			__moments[2] += (1 + n) * d2;
			__moments[2] *= r1;
			__moments[1] -= delta;
			__moments[0] = n1;
			
			__dirty = true;
		}
		
		public function remove( slot:int ):void
		{
			if ( __data[slot] > 0 )
			{
				__data[slot]--;
				
				var n:Number = __moments[0];
				var n1:Number = n - 1;
				var n2:Number = n * n;
				var delta:Number = (__moments[1] - slot) / n1;
				var d2:Number = delta * delta;
				var d3:Number = delta * d2;
				var r1:Number = n / n1;
				
				__moments[4] += 4 * delta * __moments[3] + 6 * d2 * __moments[2] + (1 + n * n2) * d2 * d2;
				__moments[4] *= r1;
				__moments[3] += 3 * delta * __moments[2] + (1 - n2) * d3;
				__moments[3] *= r1;
				__moments[2] += (1 + n) * d2;
				__moments[2] *= r1;
				__moments[1] -= delta;
				__moments[0] = n1;
				
				__dirty = true;
			}
		}
		
		public function clearSlot( slot:int ):void
		{
			if ( __data[slot] > 0 )
			{
				
				var n:Number = __moments[0];
				var n1:Number = n - __data[slot];
				var n2:Number = n * n;
				var delta:Number = (__moments[1] - (__data[slot] * slot)) / n1;
				var d2:Number = delta * delta;
				var d3:Number = delta * d2;
				var r1:Number = n / n1;
				
				__moments[4] += 4 * delta * __moments[3] + 6 * d2 * __moments[2] + (1 + n * n2) * d2 * d2;
				__moments[4] *= r1;
				__moments[3] += 3 * delta * __moments[2] + (1 - n2) * d3;
				__moments[3] *= r1;
				__moments[2] += (1 + n) * d2;
				__moments[2] *= r1;
				__moments[1] -= delta;
				__moments[0] = n1;
				__data[slot] = 0;
				__dirty = true;
			}
		}
		
		public function setSlot( slot:int, data:Number ):void
		{
			
			if ( __data[slot] > 0 )
			{
				clearSlot(slot)
			}
				
			if ( data > 0 )
			{
				var n:Number = __moments[0];
				var n1:Number = n + data;
				var n2:Number = n * n;
				var delta:Number = (__moments[1] + (data * slot)) / n1;
				var d2:Number = delta * delta;
				var d3:Number = delta * d2;
				var r1:Number = n / n1;
				
				__moments[4] += 4 * delta * __moments[3] + 6 * d2 * __moments[2] + (1 + n * n2) * d2 * d2;
				__moments[4] *= r1;
				__moments[3] += 3 * delta * __moments[2] + (1 - n2) * d3;
				__moments[3] *= r1;
				__moments[2] += (1 + n) * d2;
				__moments[2] *= r1;
				__moments[1] -= delta;
				__moments[0] = n1;
			}
			__data[slot] = data;
			
			__dirty = true;
		}
		
		
		public function get median():int
		{
			if ( __dirty )
			{
				calculate();
			}
			return __median;
		}
		
		public function get numSamples():int
		{
			return __total;
		}
		
		public function get length():int
		{
			return __size;
		}
		
		public function get probabilities():Vector.<Number>
		{
			return __probabilities.concat();
		}
		
		public function getThreshold( type:String = THRESHOLD_MOMENT ):int
		{
			if ( __dirty )
			{
				calculate();
			}
		
			switch ( type )
			{
				case THRESHOLD_ENTROPY:
					return thresh_e();
				break;
				case THRESHOLD_MOMENT:
					return thresh_m();
				break;
				case THRESHOLD_DISCRIMINANT:
					return thresh_k();
				break;
				case THRESHOLD_OTSU:
					return thresh_o();
				break;
			}
			return 0;
		}
		
		public function getMap( width:int = -1, height:int = 100, bg:uint = 0xff000000, fg:uint = 0xffffffff, normalize:Boolean = false):BitmapData
		{
			if ( __dirty )
			{
				calculate();
			}
			
			if ( __map != null ) __map.dispose();
			
			if ( width == -1 ) width = __size;
			__map = new BitmapData( width, height, true, bg );
			
			var paintMap:BitmapData;
			
			if ( width != __size )
			{
				paintMap = new BitmapData( __size, height, true, bg );
			} else {
				paintMap = __map
			}
			
			var rect:Rectangle = new Rectangle(0,0,1,0);
			for ( var i:int = 0; i < __size; i++ )
			{
				rect.x = i;
				//rect.height = height * __probabilities[i] / f;
				rect.height = height * ( __probabilities[i] - __minProbability ) / ( __maxProbability - __minProbability);
				rect.y = height-rect.height
				paintMap.fillRect( rect, fg );
			}
			
			if ( width != __size )
			{
				__map.draw( paintMap, new Matrix( width / __size,0,0,1,0,0));
				paintMap.dispose();	
			}
			
			return __map;
		}
		
		public function getProbability( index:int ):Number
		{
			if ( __dirty )
			{
				calculate();
			}
			return __probabilities[index];
		}
		
		public function getFrequency( index:int ):int
		{
			return __data[index];
		}
		
		public function get coherence():Number
		{
			if ( __dirty )
			{
				calculate();
			}
			return __coherence;
		}
		
		public function get minProbability():Number
		{
			if ( __dirty )
			{
				calculate();
			}
			return __minProbability;
		}
		
		public function get maxProbability():Number
		{
			if ( __dirty )
			{
				calculate();
			}
			return __maxProbability;
		}
		
		private function calculate():void
		{
			
				var i:int;
				__minProbability = 1;
				__maxProbability = 0;
				__maxData = 0;
				__total = 0;
				for ( i = 0; i < __size; i++)
				{
					__total += __data[i];
				}
				
				var d:int;
				for ( i = 0; i < __size; i++)
				{
					__probabilities[i] = Number( ( d = __data[i] ) / __total );
					if (__probabilities[i] < __minProbability) __minProbability = __probabilities[i];
					if (__probabilities[i] > __maxProbability) __maxProbability = __probabilities[i];
				
					if ( d > __maxData ) __maxData = d;
				}
				var sum:Number = __total / 2;
				i = 0;
				while (sum > 0)
				{
					sum -= __data[int(i++)];
				}
				__median = i - 1;
				
				// Calculate coherence:
				var isOn:Boolean = __data[0] > 0;
				var onCount:Number = isOn ? 1 : 0;
				var offCount:Number = isOn ? 0 : 1;
				
				for ( i = 1; i < __size; i++)
				{ 
					if ( __data[i] > 0 )
					{
						if ( !isOn ) 
						{
							onCount++;
							isOn = true;
						}
					} else {
						if ( isOn ) 
						{
							offCount++;
							isOn = false;
						}
					}
				}
				__coherence = ( onCount + offCount ) / __size;
				
				
				__unnormalizedVariance = __moments[2] * __moments[0];
				var n1:Number = __moments[0] - 1;
				var n2:Number = (__moments[0] - 2) * (__moments[0] - 3);
				__variance = (__moments[0] < 2 ? NaN : __unnormalizedVariance / n1);
				__standardDeviation = Math.sqrt(__variance);
				__skewness = (__moments[0] < 3 ? NaN : __moments[3] * __moments[0] * __moments[0] / (Math.sqrt(__variance) * __variance * n1 * (__moments[0] - 2)));
				__kurtosis = (__moments[0] < 4 ? NaN : (__moments[4] * __moments[0] * __moments[0] * (__moments[0] + 1) / (__variance * __variance * n1) - n1 * n1 * 3) / n2 );
				__errorOnAverage = Math.sqrt(__variance / __moments[0]);
				__dirty = false;
				
			
		}
		
		private function thresh_m():int
		{
			// moment-preservation threshold
			
			var m1:Number;
			var m2:Number;
			var m3:Number;
			
			m1 = m2 = m3 = 0;
			 
			for (var i:int = 0; i < __size; i++) 
			{
				m1 += i * __probabilities[i];
				m2 += i * i * __probabilities[i];
				m3 += i * i * i * __probabilities[i];
			}
			
			var cd:Number = m2 - m1 * m1;
			var c0:Number = (-m2 * m2 + m1 * m3) / cd;
			var c1:Number = (-m3 + m2 * m1) / cd;
			var z0:Number = 0.5 * (-c1 - Math.sqrt (c1 * c1 - 4 * c0));
			var z1:Number = 0.5 * (-c1 + Math.sqrt (c1 * c1 - 4 * c0));

			var pd:Number = z1 - z0;
			var p0:Number = (z1 - m1) / pd;
			
			var pDistr:Number = 0.0;
			for (var thresh:int = 0; thresh < __size; thresh++) 
			{
				pDistr += __probabilities[thresh];
				if (pDistr > p0)
				  break;
			}
			return thresh;
		}
		
		
		private function thresh_e():int
		{
			// maximum entropy threshold
			
			var i:int, j:int, thresh:int;
			var Ps:Number, Hs:Number, psi:Number;
			
			var Hn:Number = 0;
			
			for ( i = 0; i < __size; i++)
			{
				if ( __probabilities[i] != 0)
				{
					Hn -= __probabilities[i] * Math.log( __probabilities[i] );
				}
			}
			
			var psiMax:Number = 0;
			
			for ( i = 1; i < __size; i++ ) 
			{
				Ps = 0;
				Hs = 0; 
				for ( j = 0; j < i; j++ ) 
				{
					Ps += __probabilities[j];
					if ( __probabilities[j] > 0.0)
					{
						Hs -= __probabilities[j] * Math.log ( __probabilities[j] );
					}
				}
				
				if (Ps > 0.0 && Ps < 1.0)
				{
					psi = Math.log ( Ps - Ps * Ps ) + Hs / Ps + ( Hn - Hs ) / ( 1 - Ps );
				}
				
				if ( psi > psiMax)
				{
					psiMax = psi;
					thresh = i;
				}
			}
			return thresh;
		}
		
		
		private function thresh_k():int
		{
			// discriminant (Kittler/Illingworth) threshold
			
			var nHistM1:int = __size - 1;
			var discr:Number = 0;
			var discrM1:Number = 0;
			var discrMax:Number = 0;
			var discrMin:Number = 0;
			var i:int;
			var j:int;
			var thresh:int = 0;
			var m0Low:Number;
			var m0High:Number;
			var m1Low:Number;
			var m1High:Number;
			var varLow:Number;
			var varHigh:Number;
			
			for ( i = 1;  i < nHistM1; i++) 
			{
				m0Low = m0High = m1Low = m1High = varLow = varHigh = 0;
				for ( j = 0; j <= i; j++) 
				{
					m0Low += __probabilities[j];
					m1Low += j * __probabilities[j];
				}
				m1Low = (m0Low != 0) ? m1Low / m0Low : i;
				for (j = i + 1; j < __size; j++) 
				{
					m0High += __probabilities[j];
					m1High += j * __probabilities[j];
				}
				m1High = (m0High != 0.0) ? m1High / m0High : i;
				for (j = 0; j <= i; j++)
				{
					varLow += (j - m1Low) * (j - m1Low) * __probabilities[j];
				}
				var stdDevLow:Number = Math.sqrt (varLow);
				for (j = i + 1; j < __size; j++)
				{
					varHigh += (j - m1High) * (j - m1High) * __probabilities[j];
				}
				var stdDevHigh:Number = Math.sqrt (varHigh);
				if (stdDevLow == 0)
				{
					stdDevLow = m0Low;
				}
				if (stdDevHigh == 0)
				{
					stdDevHigh = m0High;
				}
				var term1:Number = (m0Low != 0) ? m0Low * Math.log (stdDevLow / m0Low) : 0;
				var term2:Number = (m0High != 0) ? m0High * Math.log (stdDevHigh / m0High) : 0;
				discr = term1 + term2;
				if (discr < discrM1)
				{
					discrMin = discr;
				}
				if (discrMin != 0 && discr >= discrM1)
				{
					break;
				}
				discrM1 = discr;
			}

			return i;
		}
		
		private function thresh_o():int
		{
			//  Otsu's discriminant method threshold
			
			var nHistM1:int = __size - 1;
			var i:int;
			var j:int;
			
			var thresh:int = 0
			var varWMin:Number = 100000000;
			var m0Low:Number;
			var m0High:Number;
			var m1Low:Number;
			var m1High:Number;
			var varLow:Number;
			var varHigh:Number;
			
			for (i = 1; i < nHistM1; i++)
			{
				m0Low = m0High = m1Low = m1High = varLow = varHigh = 0.0;
				for (j = 0; j <= i; j++) 
				{
					m0Low += __probabilities[j];
					m1Low += j * __probabilities[j];
				}
				m1Low = (m0Low != 0.0) ? m1Low / m0Low : i;
				for (j = i + 1; j < __size; j++) 
				{
					m0High += __probabilities[j];
					m1High += j * __probabilities[j];
				}
				m1High = (m0High != 0.0) ? m1High / m0High : i;
				for (j = 0; j <= i; j++)
				{
					varLow += (j - m1Low) * (j - m1Low) * __probabilities[j];
				}
				for (j = i + 1; j < __size; j++)
				{
					varHigh += (j - m1High) * (j - m1High) * __probabilities[j];
				}

				var varWithin:Number = m0Low * varLow + m0High * varHigh;
				if (varWithin < varWMin) 
				{
					varWMin = varWithin;
					thresh = i;
				}
			}
			
			return thresh;
		}
		
		public function getPeakCount( tolerance:int, minFactor:Number = 1.0 ):int
		{
			if ( __dirty )
			{
				calculate();
			}
			return getPeaks( tolerance, minFactor ).length;
		}
		
		public function getPeaks( radius:int = 1, minFactor:Number = 1.0 ):Vector.<int>
		{
			if ( __dirty )
			{
				calculate();
			}
			if (radius < 1) radius = 1;
			var peaks:Vector.<int> = new Vector.<int>();
			var j:int;
			var j_from:int;
			var j_to:int;
			var is_peak:Boolean;
			var current:Number;
			var sum:Number;
			for ( var i:int = 0; i < __size; i++ )
			{
				j_from = Math.max(0,i-radius );
				j_to = Math.min(__size,i+radius );
				is_peak = true;
				current =  __probabilities[i];
				sum = 0;
				for ( j = j_from; j < j_to && is_peak; j++)
				{
					if ( j!=i )
					{
						if( __probabilities[j] >= current )
						{
							is_peak = false;
						} else {
							sum += __probabilities[j];
						}
					}
				}
				if ( is_peak ) 
				{
					sum /= j_to - j_from - 1;
					if ( current > minFactor * sum )
					{
						peaks.push(i);
						i += radius-1
					}
				}
			}
			return peaks;
			
		}
		
		public function getValleys( radius:int = 1, minFactor:Number = 1.0 ):Vector.<int>
		{
			if ( __dirty )
			{
				calculate();
			}
			if (radius < 1) radius = 1;
			var valleys:Vector.<int> = new Vector.<int>();
			var j:int;
			var j_from:int;
			var j_to:int;
			var is_valley:Boolean;
			var current:Number;
			var sum:Number;
			for ( var i:int = 0; i < __size; i++ )
			{
				j_from = Math.max(0,i-radius );
				j_to = Math.min(__size,i+radius );
				is_valley = true;
				current =  __probabilities[i];
				sum = 0;
				for ( j = j_from; j < j_to && is_valley; j++)
				{
					if ( j!=i )
					{
						if( __probabilities[j] <= current )
						{
							is_valley = false;
						} else {
							sum += __probabilities[j];
						}
					}
				}
				if ( is_valley ) 
				{
					sum /= j_to - j_from - 1;
					if ( current < minFactor * sum )
					{
						valleys.push(i);
						i += radius-1
					}
				}
			}
			return valleys;
		}
		
		public function getPercentageIndex( factor:Number ):int
		{
			if ( __dirty )
			{
				calculate();
			}
			if ( factor <= 0 ) return 0;
			if ( factor >= 1 ) return __size - 1;
			
			var maxSum:Number = __total * factor;
			for ( var i:int = 0; i < __size; i++ )
			{
				maxSum -= __data[i];
				if ( maxSum <= 0 ) return i;
			}
			return __size - 1;
		}
		
		public function smooth( radius:int ):void
		{
			if ( radius < 1 ) return;
			var data:Vector.<Number> = __blank.concat();
			for ( var i:int = 0; i < __size; i++ )
			{
				var sum:Number = 0;
				var div:int = 0;
				for ( var j:int = -radius; j <= radius; j++ )
				{
					var k:int = i+j;
					if ( k >= 0 && k < __size )
					{
						div++;
						sum += __data[k];
					}
					data[i] = sum / div;
				}
			}
			
			__data = data;
			__dirty = true;
			
		}
		
		public function getMean( fromIndex:int = 0, toIndex:int = -1 ):Number
		{
			if ( fromIndex < 0 ) fromIndex = 0;
			if ( fromIndex > __size ) fromIndex = __size;
			if ( toIndex > __size || toIndex  < 0 ) toIndex = __size;
			if ( toIndex < fromIndex )
			{
				var tmp:int = toIndex;
				toIndex = fromIndex;
				fromIndex = tmp;
			}
			var sum:Number = 0;
			var count:Number = 0;
			for ( var i:int = fromIndex; i < toIndex; i++ )
			{
				sum += __data[i] * i;
				count += __data[i];
			}
			return sum / count;
		}
		
		
		
		public function getPercentage( fromIndex:int, toIndex:int ):Number
		{
			if ( fromIndex < 0 ) fromIndex = 0;
			if ( toIndex > __size ) toIndex = __size;
			var sum:Number = 0;
			for ( var i:int = fromIndex; i < toIndex; i++ )
			{
				sum += __data[i];
			}
			return sum / __total;
		}
		
		public function get unnormalizedVariance():Number
		{
			if ( __dirty ) calculate();
			return __unnormalizedVariance;
		}
		
		public function get variance():Number
		{
			if ( __dirty ) calculate();
			return __variance;
		}
		
		public function get standardDeviation():Number
		{
			if ( __dirty ) calculate();
			return __standardDeviation;
		}
		
		public function get skewness():Number
		{
			if ( __dirty ) calculate();
			return __skewness;
		}
		
		public function get kurtosis():Number
		{
			if ( __dirty ) calculate();
			return __kurtosis;
		}
		
		public function get errorOnAverage():Number
		{
			if ( __dirty ) calculate();
			return __errorOnAverage;
		}
		
		public function compare( h:Histogram, method:String ):Number
		{
			if (h.length != this.length ) return NaN;
			var i:int;
			var f1:Number;
			var f2:Number;
			var fs:Number;
			var fd:Number;
			var result:Number;
			var sum1:Number;
			var sum2:Number;
			var sum3:Number;
			
			switch ( method )
			{
				case COMP_CHI_SQUARE:
					result = 0;
					for ( i = 0; i < length; i++ )
					{
						f1 = h.getProbability(i);
						f2 = getProbability(i);
						fs = f1+f2;
						if ( fs != 0 )
						{
							fd =  f1 - f2;
							result += fd*fd/fs;
						}
					}
				break;
				case COMP_INTERSECT:
					result = 0;
					for ( i = 0; i < length; i++ )
					{
						f1 = h.getProbability(i);
						f2 = getProbability(i);
						result += f1 < f2 ? f1 : f2;
					}
				break;
				
				case COMP_CORRELATION:
					var mean1:Number = h.getMean();
					var mean2:Number = getMean();
					sum1 = 0;
					sum2 = 0;
					sum3 = 0;
					var d1:Number;
					var d2:Number;
					for ( i = 0; i < length; i++ )
					{
						f1 = h.getProbability(i);
						f2 = getProbability(i);
						d1 = (f1-mean1);
						d2 = (f2-mean2);
						sum1 += d1*d2;
						sum2 += d1*d1;
						sum3 += d2*d2;
					}
					result = sum1 / Math.sqrt(sum2*sum3);
					break;
				
				case COMP_BHATTACHARYYA:
					sum1 = 0;
					sum2 = 0;
					sum3 = 0;
					
					for ( i = 0; i < length; i++ )
					{
						sum2 += h.getProbability(i);
						sum3 += getProbability(i);
					}
					var mean:Number = Math.sqrt(sum2 * sum3);
					for ( i = 0; i < length; i++ )
					{
						sum1 += Math.sqrt(h.getProbability(i) * getProbability(i)) / mean;
						
					}
					result = Math.sqrt( 1 - sum1 );
					break;
			}
			
			return result;
		}
		
		public function getMatchHistogramLUT ( match:Histogram, bitShift:int = 0 ):Array
		{
			if ( __size != match.length ) return null;
			
			var PA:Vector.<Number> = Cdf(); // get CDF of histogram hA
			var PR:Vector.<Number> = match.Cdf(); // get CDF of histogram hR
			var F:Array = []; // pixel mapping function f()
			
			// compute pixel mapping function f():
			for (var a:int = 0; a < __size; a++) {
				var j:int = __size - 1;
				do {
					F[a] = j << bitShift;
					j--;
				} while (j >= 0 && PA[a] <= PR[j]);
			}
			return F;
		}
		
		
		public function Cdf():Vector.<Number> 
		{
			// returns the cumul. probability distribution function (cdf) for histogram h
			var n:Number = 0;		// sum all histogram values		
			for (var i:int = 0; i < __size; i++)	
			{ 	
				n += __data[i]; 
			}
			var P:Vector.<Number> = new Vector.<Number>(__size,true);
			var c:Number = __data[0];
			P[0] = c / n;
			for ( i=1; i<__size; i++) {
				c += __data[i];
				P[i] = c / n; 
			}
			return P;
		}
		
	}
}