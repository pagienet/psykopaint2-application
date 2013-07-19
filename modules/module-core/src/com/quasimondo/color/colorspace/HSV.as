package com.quasimondo.color.colorspace
{
	public class HSV implements IColorSpace
	{
		private var _hue: int;
		private var _saturation: int;
		private var _value: int;
		
		/**
		 * Constructor.
		 * 
		 * <p>Initilizes the colorspace container</p>. 
		 * 
		 * @param h Value for hue
		 * @param s Value for saturation
 		 * @param v Value for value
  		 */
		public function HSV( h: int = 0, s: int = 100, v: int = 0 )
		{
			hue = h;
			saturation = s;
			value = v;
		}

		[Bindable]		
		/**
		 * Getter method for hue data.
		 * 
		 * @return int
 		 */
		public function get hue(): int
		{
			return _hue;
		}

		/**
		 * Setter method for hue data.
		 * 
		 * @param h Hue value
 		 */
		public function set hue( h: int ): void
		{
			h = h % 360;
			if ( h == 360 ) h = 0;
			else if ( h < 0 ) h += 360;
			_hue = h;
		}
		
		[Bindable]
		/**
		 * Getter method for saturation data.
		 * 
		 * @return int
 		 */
		public function get saturation(): int
		{
			return _saturation;
		}

		/**
		 * Setter method for saturation data.
		 * 
		 * @param s Saturation value
 		 */
		public function set saturation( s: int ): void
		{
			if ( s < 0 ) s = 0;
			else if ( s > 100 ) s = 100;
			_saturation = s;
		}
		
		[Bindable]
		/**
		 * Getter method for value data.
		 * 
		 * @return int
 		 */
		public function get value(): int
		{
			return _value;
		}

		/**
		 * Setter method for value data.
		 * 
		 * @param v Value value
 		 */
		public function set value( v: int ): void
		{
			if ( v < 0 ) v = 0;
			else if ( v > 100 ) v = 100;
			_value = v;
		}
		
		public function clone():HSV
		{
			return new HSV(_hue,_saturation,_value);	
		}
		
		public function toString( ): String
		{
			return "hsv(" + _hue + ", " + _saturation + ", " + _value + ")";
		}		
		
	}
}