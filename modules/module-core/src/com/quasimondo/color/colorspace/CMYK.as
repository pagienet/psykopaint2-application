package com.quasimondo.color.colorspace
{
	public class CMYK implements IColorSpace
	{
		private var _cyan: int;
		private var _magenta: int;
		private var _yellow: int;
		private var _black: int;
		
		/**
		 * Constructor.
		 * 
		 * <p>Initilizes the colorspace container</p>. 
		 * 
		 * @param c Value for cyan
		 * @param m Value for magenta
 		 * @param y Value for yellow
 		 * @param k Value for black
  		 */
		public function CMYK( c: int = 0, m: int = 0, y: int = 0, k: int = 100 )
		{
			cyan = c;
			magenta = m;
			yellow = y;
			black = k;
		}
		
		/**
		 * Setter method for Cyan data.
		 * 
		 * @param c Cyan value
 		 */
		public function set cyan( c: int ): void
		{
			if ( c < 0 ) c = 0;
			else if ( c > 100 ) c = 100;
			_cyan = c;
		}
		
		[Bindable]
		/**
		 * Getter method for cyan data.
		 * 
		 * @return int
 		 */
		public function get cyan(): int
		{
			return _cyan;
		}

		/**
		 * Setter method for magenta data.
		 * 
		 * @param m Magenta value
 		 */
		public function set magenta( m: int ): void
		{
			if ( m < 0 ) m = 0;
			else if ( m > 100 ) m = 100;
			_magenta = m;
		}

		[Bindable]
		/**
		 * Getter method for magenta data.
		 * 
		 * @return int
 		 */
		public function get magenta(): int
		{
			return _magenta;
		}

		/**
		 * Setter method for yellow data.
		 * 
		 * @param y Yellow value
 		 */
		public function set yellow( y: int ): void
		{
			if ( y < 0 ) y = 0;
			else if ( y > 100 ) y = 100;
			_yellow = y;
		}

		[Bindable]
		/**
		 * Getter method for yellow data.
		 * 
		 * @return int
 		 */
		public function get yellow(): int
		{
			return _yellow;
		}

		/**
		 * Setter method for black data.
		 * 
		 * @param b Black value
 		 */
		public function set black( k: int ): void
		{
			if ( k < 0 ) k = 0;
			else if ( k > 100 ) k = 100;
			_black = k;
		}

		[Bindable]
		/**
		 * Getter method for black data.
		 * 
		 * @return int
 		 */
		public function get black(): int
		{
			return _black;
		}
		
		public function clone():CMYK
		{
			return new CMYK(_cyan, _magenta, _yellow,  _black );
		}
		
		public function toString( ): String
		{
			return "cmyk(" + _cyan + ", " + _magenta + ", " + _yellow + ", " + _black + ")";
		}		

	}
}