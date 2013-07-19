package com.quasimondo.color.colorspace
{
	public class ARGB extends RGB
	{
		private var _alpha: int;
		
		public function ARGB( r: Number = 0, g: Number = 0, b: Number = 0, a: Number = 0 )
		{
			super( r, g, b );
			alpha = a;
		}
		
		public function get alphaColor( ): uint
		{
			return alpha << 24 | red << 16 | green << 8 | blue;
		}
		
		public function get alpha( ): int
		{
			return _alpha;
		}
		
		public function set alpha( value: int ): void
		{
			_alpha = Math.min( Math.max( value, 0 ), 255 );
		}
		
		static public function invert( value: ARGB ): ARGB
		{
        	return new ARGB( 255 - value.red, 255 - value.green, 255 - value.blue, value.alpha );
    	}
		
		public static function fromRGB( value: RGB ): ARGB
		{
			return new ARGB( value.red, value.green, value.blue, 255 );
		}

	    static public function fromRGBUint(value:uint): ARGB
	    {
	    	return new ARGB( value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, 255 );
	    }

	    /**
	     * 
	     * @param value    value
	     */
	    static public function fromARGBUint(value:uint): ARGB
	    {
	    	return new ARGB( value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, value >> 24 & 0xFF );
	    }

	    /**
	     * 
	     * @param c    c
	     */
	    static public function fromrRGBUintToWebsafe(c:uint): ARGB
	    {
			var argb: ARGB = fromRGBUint( c );
			argb.red   = Math.round( argb.red / 51 ) * 51;
			argb.green = Math.round( argb.green / 51 ) * 51;
			argb.blue  = Math.round( argb.blue / 51 ) * 51;
			return argb;	    	
	    }
	    
		override public function toString( ): String
		{
			return "argb(" + red + ", " + green + ", " + blue + ", " + alpha + ")";
		}	    

		override public function clone( ): IRGB
		{
			return new ARGB( red, green, blue, alpha );
		}
		
	}
}