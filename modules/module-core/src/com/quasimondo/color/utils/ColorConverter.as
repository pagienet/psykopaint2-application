package com.quasimondo.color.utils
{
	import com.quasimondo.color.colorspace.ARGB;
	import com.quasimondo.color.colorspace.CMYK;
	import com.quasimondo.color.colorspace.HEX;
	import com.quasimondo.color.colorspace.HSL;
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.colorspace.IColorSpace;
	import com.quasimondo.color.colorspace.IRGB;
	import com.quasimondo.color.colorspace.RGB;
	
	import flash.utils.Dictionary;
	
	public class ColorConverter
	{
		
		/**
		 * Lookup tables
		 */
		 private static var rgb_hsv_lookup: Dictionary  = new Dictionary();
		 private static var hsv_rgb_lookup: Dictionary  = new Dictionary();
		 private static var rgb_hex_lookup: Dictionary  = new Dictionary();
		 private static var hex_rgb_lookup: Dictionary  = new Dictionary();
		 private static var rgb_cmyk_lookup: Dictionary = new Dictionary();
		 private static var cmyk_rgb_lookup: Dictionary = new Dictionary();
		 private static var rgb_hsl_lookup: Dictionary  = new Dictionary();
		 private static var hsl_rgb_lookup: Dictionary  = new Dictionary();
		 
		/**
		 * Converts <code>RGB</code> data to <code>HSV</code> data.
		 * 
		 * @param rgb Data to be converted
		 * @param Converted data
  		 */
		public static function RGBtoHSV( rgb: IRGB ): HSV
		{
			if ( !rgb_hsv_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
			{
				var min: Number;
				var max: Number;
				var delta: Number;
				var h: Number;
				var s: Number;
				var v: Number;
	
				min = Math.min( rgb.red, Math.min( rgb.green, rgb.blue ) );
				max = Math.max( rgb.red, Math.max( rgb.green, rgb.blue ) );
				
				v = Math.round( max * ( 100 / 255 ) );
				delta = max - min;
				
				if ( max != 0 )
					s = Math.round( 100 * ( delta / max ) );
				else
					return new HSV( -1, 0, v );

				if ( rgb.red == max)
					h = ( rgb.green - rgb.blue ) * 60 / delta;
				else if ( rgb.green == max )
					h = ( 2 + ( rgb.blue - rgb.red ) / delta ) * 60;
				else
					h = ( 4 + ( rgb.red - rgb.green ) / delta ) * 60;
	
				h = h % 360;
				if ( h < 0 )
					h += 360;
				
				rgb_hsv_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new HSV( Math.round( h ), s, v );
			}

			return HSV(rgb_hsv_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ]).clone();
		}
		
		/**
		 * Converts <code>HSV</code> data to <code>RGB</code> data.
		 * 
		 * @param hsv Data to be converted
		 * @return Converted data
  		 */
		public static function HSVtoRGB( hsv: HSV ): RGB
		{
			if ( !hsv_rgb_lookup[ hsv.hue << 16 | hsv.saturation << 8 | hsv.value ] )
			{
				var min: Number;
				var delta: Number;
				var r: Number;
				var g: Number;
				var b: Number;
				var h: Number = Math.round( hsv.hue );
				var s: Number = Math.round( hsv.saturation * ( 255 / 100 ) );
				var v: Number = Math.round( hsv.value * ( 255 / 100 ) );
	
				if ( !h && !s )
				{
					r = v;
					g = v;
					b = v;
				}else
				{
					delta = ( v * s ) / 255;
					min = v - delta;
					if ( h>300 || h<=60 )
					{
						r = v;
						if ( h>300 )
						{
							g = Math.round( min );
							h = ( h - 360 ) / 60;
							b = -Math.round( h * delta - min );
						}else
						{
							b = Math.round( min );
							h = h / 60;
							g = Math.round( h * delta + min );
						}
					}else if ( h>60 && h<180 )
					{
						g = v;
						if ( h<120 )
						{
							b = Math.round( min );
							h = ( h / 60 - 2 ) * delta;
							r = Math.round( min - h );
						}else
						{
							r = Math.round( min );
							h = ( h / 60 - 2 ) * delta;
							b = Math.round( min + h );
						}
					}else
					{
						b = v;
						if ( h<240 )
						{
							r = Math.round( min );
							h = ( h / 60 - 4 ) * delta;
							g = Math.round( min - h );
						}else
						{
							g = Math.round( min );
							h = ( h / 60 - 4 ) * delta;
							r = Math.round( min + h );
						}
					}
				}
				hsv_rgb_lookup[ hsv.hue << 16 | hsv.saturation << 8 | hsv.value ] = new RGB( r, g, b );
			}		

			return RGB(RGB(hsv_rgb_lookup[ hsv.hue << 16 | hsv.saturation << 8 | hsv.value ]).clone());
		}
		
		public static function HSVtoARGB( hsv: HSV, alpha: int = 255 ): ARGB
		{
			var rgb: RGB = HSVtoRGB( hsv );
			return new ARGB( rgb.red, rgb.green, rgb.blue, alpha );
		}
		
		/**
		 * Converts <code>RGB</code> data to <code>HEX</code> data.
		 * 
		 * @param rgb Data to be converted
		 * @return Converted data
  		 */
		public static function RGBtoHEX( rgb: IRGB ): HEX
		{
			if ( !rgb_hex_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
				rgb_hex_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new HEX( NumberConverter.intToHex( rgb.red ) + NumberConverter.intToHex( rgb.green ) + NumberConverter.intToHex( rgb.blue ) );

			return HEX(rgb_hex_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ]).clone(); 
		}

		/**
		 * Converts <code>HEX</code> data to <code>RGB</code> data.
		 * 
		 * @param hex Data to be converted
		 * @return Converted data
  		 */
		public static function HEXtoRGB( hex: HEX ): RGB
		{
			if ( !hex_rgb_lookup[ hex.value ] )
				hex_rgb_lookup[ hex.value ] = new RGB( NumberConverter.hexToInt( hex.red ), NumberConverter.hexToInt( hex.green ), NumberConverter.hexToInt( hex.blue ) );

			return RGB(RGB(hex_rgb_lookup[ hex.value ]).clone());
		}
		
		public static function HEXtoARGB( hex: HEX, alpha: int = 255 ): ARGB
		{
			var rgb: RGB = HEXtoRGB( hex );
			return new ARGB( rgb.red, rgb.green, rgb.blue, alpha );
		}
		
		/**
		 * Converts <code>uint</code> data to <code>RGB</code> data.
		 * 
		 * @param hex Data to be converted
		 * @return Converted data
  		 */
		public static function UINTtoRGB( value: uint ): RGB
		{
			return new RGB( value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF );
		}
		
		public static function RGBtoUINT( value: IRGB ): uint
		{
			return value.red << 16 | value.green << 8 | value.blue;
		}
		
		public static function UINTtoARGB( value: uint ): ARGB
		{
			return new ARGB( value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, value >> 24 & 0xFF );
		}
		
		public static function ARGBToUINT( value: ARGB ): uint
		{
			return value.alpha << 24 | value.red << 16 | value.green << 8 | value.blue;
		}
		
		public static function UINTtoHSL( value: uint ): HSL
		{
			return RGBtoHSL(new RGB( value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF));
		}

		/**
		 * Converts <code>CMYK</code> data to <code>RGB</code> data.
		 * 
		 * @param cmyk Data to be converted
		 * @return Converted data
  		 */
		public static function CMYKtoRGB( cmyk: CMYK ): RGB
		{
			if ( !cmyk_rgb_lookup[ cmyk.cyan << 24 | cmyk.magenta << 16 | cmyk.yellow << 8 | cmyk.black ] )
			{
				var k: Number = 1 - cmyk.black / 100;
				var r: Number = Math.round( ( 255 - cmyk.cyan * 2.55 ) * k );
				var g: Number = Math.round( ( 255 - cmyk.magenta * 2.55 ) * k );
				var b: Number = Math.round( ( 255 - cmyk.yellow * 2.55 ) * k );
				
				cmyk_rgb_lookup[ cmyk.cyan << 24 | cmyk.magenta << 16 | cmyk.yellow << 8 | cmyk.black ] = new RGB( r, g, b );
			}

			return RGB(RGB(cmyk_rgb_lookup[ cmyk.cyan << 24 | cmyk.magenta << 16 | cmyk.yellow << 8 | cmyk.black ]).clone());
		}
		
		public static function CMYKtoARGB( cmyk: CMYK, alpha: int = 255 ): ARGB
		{
			var rgb: RGB = CMYKtoRGB( cmyk );
			return new ARGB( rgb.red, rgb.green, rgb.blue, alpha );
		}		

		/**
		 * Converts <code>RGB</code> data to <code>CMYK</code> data.
		 * 
		 * @param rgb Data to be converted
		 * @return Converted data
  		 */
		public static function RGBtoCMYK( rgb: IRGB ): CMYK
		{
			if ( !rgb_cmyk_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
			{
				var c: Number = 1 - rgb.red / 255;
				var m: Number = 1 - rgb.green / 255;
				var y: Number = 1 - rgb.blue / 255;
				var k: Number = Math.min( c, Math.min( m, Math.min( y, 1 ) ) );
				c = Math.round( ( c - k ) / ( 1 - k ) * 100 );
				m = Math.round( ( m - k ) / ( 1 - k ) * 100 );
				y = Math.round( ( y - k ) / ( 1 - k ) * 100 );
				k = Math.round( k * 100 );
			
				rgb_cmyk_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new CMYK( c, m, y, k );
			}

			return CMYK(rgb_cmyk_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ]).clone();
		}

		/**
		 * Converts <code>RGB</code> data to <code>HSL</code> data.
		 * 
		 * @param rgb Data to be converted
		 * @return Converted data
  		 */
		public static function RGBtoHSL( rgb: IRGB ): HSL
		{
			if ( !rgb_hsl_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
			{
				var min: Number;
				var max: Number;
				var delta: Number;
				var h: Number;
				var s: Number;
				var l: Number;
	
				min = Math.min( rgb.red, Math.min( rgb.green, rgb.blue ) );
				max = Math.max( rgb.red, Math.max( rgb.green, rgb.blue ) );
				
				l = Math.round( ( ( max + min ) / 2 ) * ( 100 / 255 ) );
				delta = max - min;

				if ( max != 0 )
				{
					if ( l <= 50 )
						s = delta / ( max + min );
					else
						s = delta / ( ( 2 * 255 ) - max - min );
					
					s = Math.round( s * 100 );
				}
				else
				{
					l = Math.round( l * ( 100 / 255 ) );
					return new HSL( -1, 0, l );
				}

				if ( rgb.red == max)
					h = ( rgb.green - rgb.blue ) * 60 / delta;
				else if ( rgb.green == max )
					h = ( 2 + ( rgb.blue - rgb.red ) / delta ) * 60;
				else
					h = ( 4 + ( rgb.red - rgb.green ) / delta ) * 60;
	
				h = h % 360;
				if ( h < 0 )
					h += 360;
				
				rgb_hsl_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new HSL( Math.round( h ), s, l );
			}

			return HSL(rgb_hsl_lookup[ rgb.red << 16 | rgb.green << 8 | rgb.blue ]).clone();
			
		}

		/**
		 * Converts <code>HSL</code> data to <code>IRGB</code> data.
		 * 
		 * @param hsl Data to be converted
		 * @return Converted data
  		 */
		public static function HSLtoRGB( hsl: HSL ): RGB
		{
			if ( !hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ] )
			{
				var r: Number;
				var g: Number;
				var b: Number;
				var h: Number = hsl.hue;
				var s: Number = hsl.saturation / 100;
				var l: Number = hsl.lightness / 100;
				
				if ( s == 0 )
				{
					r = g = b = l * 255;
				}
				else
				{
					var val1: Number;
					var val2: Number;
					if ( l <= 50 )
						val2 = l * ( 1 + s );
					else
						val2 = ( l + s - l * s );
					val1 = 2 * l - val2;
					
					r = innerHSLtoRGB( val1, val2, h + 120 );
					g = innerHSLtoRGB( val1, val2, h );
					b = innerHSLtoRGB( val1, val2, h - 120 );					
				}

				hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ] = new RGB( r, g, b );
			}		

			return RGB(RGB(hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ]).clone());
		}
		
		/**
		 * Converts <code>HSL</code> data to <code>IRGB</code> data.
		 * 
		 * @param hsl Data to be converted
		 * @return Converted data
		 */
		public static function HSLtoUINT( hsl: HSL ): uint
		{
			if ( !hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ] )
			{
				var r: Number;
				var g: Number;
				var b: Number;
				var h: Number = hsl.hue;
				var s: Number = hsl.saturation / 100;
				var l: Number = hsl.lightness / 100;
				
				if ( s == 0 )
				{
					r = g = b = l * 255;
				}
				else
				{
					var val1: Number;
					var val2: Number;
					if ( l <= 50 )
						val2 = l * ( 1 + s );
					else
						val2 = ( l + s - l * s );
					val1 = 2 * l - val2;
					
					r = innerHSLtoRGB( val1, val2, h + 120 );
					g = innerHSLtoRGB( val1, val2, h );
					b = innerHSLtoRGB( val1, val2, h - 120 );					
				}
				
				hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ] = new RGB( r, g, b );
			}		
			var rgb:RGB = hsl_rgb_lookup[ hsl.hue << 16 | hsl.saturation << 8 | hsl.lightness ];
			return 0xff000000 | rgb.red << 16 | rgb.green << 8 | rgb.blue;
		}
		
		
		public static function HSLtoARGB( hsl: HSL, alpha: int = 255 ): ARGB
		{
			var rgb: RGB = HSLtoRGB( hsl );
			return new ARGB( rgb.red, rgb.green, rgb.blue, alpha );
		}
		
		
		public static function AnyToHSL( color:IColorSpace ):HSL
		{
			if ( color is HSL )
			{
				return color as HSL;
			}
			if ( color is RGB || color is ARGB )
			{
				return RGBtoHSL( color as RGB );
			}
			if ( color is HSV )
			{
				return RGBtoHSL( HSVtoRGB(color as HSV));
			}
			if ( color is HEX )
			{
				return RGBtoHSL( HEXtoRGB(color as HEX));
			}
			if ( color is CMYK )
			{
				return RGBtoHSL( CMYKtoRGB(color as CMYK));
			}
			return new HSL();
		}

		/**
		 * Converts <code>HSL</code> data to <code>RGB</code> data.
		 * 
		 * @param val1 First value
		 * @param val2 Second value
 		 * @param h Hue value
 		 * @return Converted data
  		 */
		private static function innerHSLtoRGB( val1: Number, val2: Number, h: Number ): Number
		{
			h = h % 360;
			if ( h == 360 ) h = 0;
			else if ( h < 0 ) h += 360;
			
			if ( h < 60 )
				val1 = val1 + ( val2 - val1 ) * h / 60;
			else if ( h < 180 )
				val1 = val2;
			else if ( h < 240 )
				val1 = val1 + ( val2 - val1 ) * ( 240 - h ) / 60;
			
			return val1 * 255;
		}
	}
}