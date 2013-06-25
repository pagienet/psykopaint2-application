package de.popforge.math
{
	public class LCG implements IRandom
	{
		
		
		private var seed: uint;
		private var m_seed0:uint;
		private var m_seed1:uint;
		private var m_seed2:uint;
		
		public function LCG( seed: uint )
		{
			setSeed( seed );
		}
		
		public function setSeed( seed:uint ):void
		{
			this.seed = seed;
			
			m_seed0 = (69069*seed) & 0xffffffff;
			if (m_seed0<2) {
	            m_seed0+=2;
	        }
	
	        m_seed1 = (69069*m_seed0) & 0xffffffff;;
	        if (m_seed1<8) {
	            m_seed1+=8;
	        }
	
	        m_seed2 = ( 69069 *m_seed1) & 0xffffffff;;
	        if (m_seed2<16) {
	            m_seed2+=16;
	        }
			
		}
		
		public function getNumber( min: Number = 0, max: Number = 1 ): Number
		{
			return min + getNextInt() / uint( 0xffffffff) * ( max - min );
		}
		
		
		public function getNextInt(): uint
		{
			m_seed0 = ((( m_seed0 & 4294967294) << 12 )& 0xffffffff)^((((m_seed0<<13)&0xffffffff)^m_seed0) >>> 19 );
       		m_seed1 = ((( m_seed1 & 4294967288) << 4) & 0xffffffff)^((((m_seed1<<2)&0xffffffff)^m_seed1)>>>25)
        	m_seed2=  ((( m_seed2 & 4294967280) << 17) & 0xffffffff)^((((m_seed2<<3)&0xffffffff)^m_seed2)>>>11)
        	return m_seed0 ^ m_seed1 ^ m_seed2;
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
	}
}


