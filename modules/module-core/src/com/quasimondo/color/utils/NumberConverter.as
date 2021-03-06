package com.quasimondo.color.utils
{
	public class NumberConverter
	{
		public static function intToHex( val: int ): String
		{
			if ( !val || isNaN( val ) || val < 0 )
			{
				val = 0;
			} else if ( val > 255 )
			{
				val = 255;
			}

			var hex_values: String = "0123456789abcdef";
			return hex_values.charAt( ( val - val % 16 ) / 16 ) + hex_values.charAt( val % 16 );
		}

		public static function hexToInt( val: String ): int
		{
			var hex: int = parseInt( val, 16 );
			if ( isNaN( hex ) )
			{
				return 0;
			} else {
				return hex;
			}
		}
	}
}