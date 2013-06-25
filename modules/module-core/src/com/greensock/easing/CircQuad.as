package com.greensock.easing {
	public class CircQuad {
		
		public static function easeIn (t:Number, b:Number, c:Number, d:Number):Number {
			return 0.5 * ( (-c * (Math.sqrt(1 - (t/=d)*t) - 1) + b) + ( c*t*t + b ));
		}
		public static function easeOut (t:Number, b:Number, c:Number, d:Number):Number {
			return 0.5 * ((-c *(t/=d)*(t-2) + b) + ( c * Math.sqrt(1 - (t=t-1)*t) + b));
		}
		public static function easeInOut (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d*0.5) < 1) return 0.5*((-c*0.5 * (Math.sqrt(1 - t*t) - 1) + b) +(c*0.5*t*t + b));
			return 0.5 * ((-c*0.5 * ((--t)*(t-=2) - 1) + b) + (c*0.5 * (Math.sqrt(1 - (t+=1)*t) + 1) + b));
		}
	}
}

