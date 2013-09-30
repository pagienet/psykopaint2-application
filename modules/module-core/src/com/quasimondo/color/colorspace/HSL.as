package com.quasimondo.color.colorspace
{
	public class HSL implements IColorSpace
	{
		private var _hue: Number;
		private var _saturation: Number;
		private var _lightness: Number;

		public function HSL( h:Number = 0, s:Number = 100, l:Number = 100 )
		{
			hue = h;
			saturation = s;
			lightness = l;
		}

		[Bindable]
		/**
		 * Getter method for hue data.
		 * 
		 * @return int
 		 */
		public function get hue(): Number
		{
			return _hue;
		}

		/**
		 * Setter method for hue data.
		 * 
		 * @param h Hue value
 		 */
		public function set hue( h: Number ): void
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
		public function get saturation(): Number
		{
			return _saturation;
		}

		/**
		 * Setter method for saturation data.
		 * 
		 * @param s Saturation value
 		 */
		public function set saturation( s: Number ): void
		{
			if ( s < 0 ) s = 0;
			else if ( s > 100 ) s = 100;
			_saturation = s;
		}
		
		[Bindable]
		/**
		 * Getter method for lightness data.
		 * 
		 * @return int
 		 */
		public function get lightness(): Number
		{
			return _lightness;
		}

		/**
		 * Setter method for lightness data.
		 * 
		 * @param v Value value
 		 */
		public function set lightness( l: Number ): void
		{
			if ( l < 0 ) l = 0;
			else if ( l > 100 ) l = 100;
			_lightness = l;
		}
		
		public function clone():HSL
		{
			return new HSL( _hue,_saturation,_lightness);
			
		}
		
		public function toString( ): String
		{
			return "hsl(" + _hue + ", " + _saturation + ", " + _lightness + ")";
		}		
	}
}