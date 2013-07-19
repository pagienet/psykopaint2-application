package com.quasimondo.color.colorspace
{
	public class RGB implements IColorSpace, IRGB
	{	
		private var _red: int;
		private var _green: int;
		private var _blue: int;
		
		/**
		 * Constructor.
		 * 
		 * <p>Initilizes the colorspace container</p>. 
		 * 
		 * @param r Value for red
		 * @param g Value for green
 		 * @param b Value for blue
  		 */
		public function RGB( r: Number = 0, g: Number = 0, b: Number = 0 )
		{
			red   = Math.round( r );
			green = Math.round( g );
			blue  = Math.round( b );
		}

		/**
		 * Getter method for red data.
		 * 
		 * @return int
 		 */
		public function get red(): int
		{
			return _red;
		}

		/**
		 * Setter method for red data.
		 * 
		 * @param r Red value
 		 */
		public function set red( r: int ): void
		{
			if ( r < 0 ) r = 0;
			else if ( r > 255 ) r = 255;
			_red = r;
		}

		/**
		 * Getter method for green data.
		 * 
		 * @return int
 		 */
		public function get green(): int
		{
			return _green;
		}

		/**
		 * Setter method for green data.
		 * 
		 * @param g Green value
 		 */
		public function set green( g: int ): void
		{
			if ( g < 0 ) g = 0;
			else if ( g > 255 ) g = 255;
			_green = g;
		}
		
		/**
		 * Getter method for blue data.
		 * 
		 * @return int
 		 */
		public function get blue(): int
		{
			return _blue;
		}

		/**
		 * Setter method for blue data.
		 * 
		 * @param b Blue value
 		 */
		public function set blue( b: int ): void
		{
			if ( b < 0 ) b = 0;
			else if ( b > 255 ) b = 255;
			_blue = b;
		}
		
		public function toString( ): String
		{
			return "rgb(" + _red + ", " + _green + ", " + _blue + ")";
		}
		
	    public function get color(): uint
	    {
	    	return red << 16 | green << 8 | blue;
	    }

	    /**
	     * 
	     * @param value    value
	     */
	    public function set color(value:uint): void
	    {
			red   = value >> 16 & 0xFF;
			green = value >> 8 & 0xFF;
			blue  = value & 0xFF;	    	
	    }
		
		
		public function clone( ): IRGB
		{
			return new RGB( red, green, blue );
		}
	}
}