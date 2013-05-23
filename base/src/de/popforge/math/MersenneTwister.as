package de.popforge.math
{
	public class MersenneTwister implements IRandom
	{
		
		private static const M:int = 397;
		private static const N:int = 624;
		private static const MATRIX_A:uint = 0x9908b0df;
		private static const UMASK:uint = 0x80000000;
		private static const LMASK:uint = 0x7fffffff;
		
		private var _state:Array = new Array( N );
		private var _left:int;
		private var _next:int;
		
		public function MersenneTwister( seed:Number = NaN )
		{
			if ( isNaN(seed) ) seed = 0;
			setSeed ( uint(seed));
		}
		
		public function setSeed(seed:uint):void 
		{
			_state[0] = seed;
			for (var j:int = 1; j<N; j++) 
			{
				_state[j] = ( imul(1812433253, _state[int(j-1)] ^ (_state[int(j-1)] >>> 30)) + j ) & 0xffffffff;
			}
			_left = 1;
		}
		
		private function imul(a:uint, b:uint):uint 
		{
			var al:uint = a & 0xffff;
			var ah:uint = a >>> 16;
			var bl:uint = b & 0xffff
			var bh:uint = b >>> 16;
			var ml:uint = al*bl
			var mh:uint = ((((ml >>> 16)+al*bh) & 0xffff)+ah*bl) & 0xffff;
			return (mh << 16) | (ml & 0xffff);
		}
		
		public function getNumber( min: Number = 0, max: Number = 1 ): Number
		{
			return min + getNextInt() / uint(0xffffffff) * ( max - min );
		}
		
		public function getNextInt():uint
		{
			var y:uint;
			if (--_left == 0) 
			{
				nextState();
			}
			y = _state[int(_next++)];
			y ^= (y >>> 11);
			y ^= (y << 7) & 0x9d2c5680;
			y ^= (y << 15) & 0xefc60000;
			y ^= (y >>> 18);
			return y;
		}
		
		public function getMappedNumber( min: Number = 0, max: Number = 1, easingFunction:Function = null):Number
		{
			var v:Number =  getNextInt() / uint( 0xffffffff);
			if ( easingFunction ) v = easingFunction.apply( null, [v,0,1,1]);
			return min + v * ( max -min );
		}
		
		public function getChance( chance:Number = 0.5 ):Boolean
		{
			return (getNextInt() / uint(0xffffffff)) < chance;
		}
		
		private function nextState():void 
		{
			var p:int = 0
			var j:int;
			
			_left = N;
			_next = 0;
			for ( j = N-M+1; --j; p++ ) 
			{
				_state[p] = _state[int(p+M)] ^ twist(_state[p], _state[int(p+1)]);
			}
			
			for ( j = M; --j; p++ ) 
			{
				_state[p] = _state[int(p+M-N)] ^ twist(_state[p], _state[int(p+1)]);
			}
			_state[p] = _state[int(p+M-N)] ^ twist(_state[p], _state[0]);
		}
		
		private function twist(u:uint, v:uint):uint 
		{
			return ((mixbits(u, v) >>> 1) ^ (v & 1 ? MATRIX_A : 0));
		}
		
		private function mixbits(u:uint, v:uint):uint 
		{
			return (u & UMASK) | (v & LMASK);
		}
		
	}

}