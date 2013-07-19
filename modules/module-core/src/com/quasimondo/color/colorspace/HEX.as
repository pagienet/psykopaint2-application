package com.quasimondo.color.colorspace
{
	public class HEX implements IColorSpace
	{
		private var _value: String;

		/**
		 * Constructor.
		 * 
		 * <p>Initilizes the colorspace container. Checks that the passed parameter is a correct value.</p>. 
		 * 
		 * @param value A string representation of the hex color
  		 */
		public function HEX( value: String = "000000" )
		{
			value = value.toLowerCase();

			if ( value.substr( 0, 1 ) == "#" )
				value = value.substr( 1 );
			else if ( value.substr( 0, 2 ) == "0x" )
				value = value.substr( 2 );

			if( value.length < 6 )
			{
				while( value.length < 6 )
				{
					value += "0";
				}
			} else if( value.length > 6 )
			{
				value = value.substr( 0, 6 );
			}

			if ( value.length != 6 || isNaN( parseInt( "0x" + value, 16 ) ) )
				value = "000000";

			_value = value;
		}


		[Bindable]
		/**
		 * Getter method for hex data.
		 * 
		 * @return A <code>String</code> representation of the color
 		 */
		public function get value(): String
		{
			return _value;
		}

		/**
		 * Setter method for hex data.
		 * 
		 * @param v A <code>String</code> representation of the color
 		 */
		public function set value( v: String): void
		{
			_value = v;
		}

		/**
		 * Getter method for red data.
		 * 
		 * @return A <code>String</code> representation of the color
 		 */
		public function get red(): String
		{
			return _value.substr( 0, 2 );
		}

		/**
		 * Getter method for green data.
		 * 
		 * @return A <code>String</code> representation of the color
 		 */
		public function get green(): String
		{
			return _value.substr( 2, 2 );
		}

		/**
		 * Getter method for blue data.
		 * 
		 * @return A <code>String</code> representation of the color
 		 */
		public function get blue(): String
		{
			return _value.substr( 4, 2 );
		}
		
		public function clone():HEX
		{
			return new HEX(_value);
		}
		
		public function toString( ): String
		{
			return "hex(" + _value + ")";
		}		

	}
}