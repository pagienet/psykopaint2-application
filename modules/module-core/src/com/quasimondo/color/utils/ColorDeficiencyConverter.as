package com.quasimondo.color.utils
{
	import com.quasimondo.color.colorspace.RGB;
	
	import flash.utils.Dictionary;
	
	public class ColorDeficiencyConverter
	{

		/**
		 * Default values for color deficiency
		 */
		private static var blind_map: Object =
		{
			protan: { cpu: 0.735, cpv: 0.265, abu: 0.115807, abv: 0.073581, aeu: 0.471899, aev: 0.527051 },
			deutan: { cpu: 1.14, cpv: -0.14, abu: 0.102776, abv: 0.102864, aeu: 0.505845, aev: 0.493211 },
			tritan: { cpu: 0.171, cpv: -0.003, abu: 0.045391, abv: 0.294976, aeu: 0.665764, aev: 0.334011 }
		};

		public static const TYPE_PROTAN: String		= "protan";
		public static const TYPE_DEUTAN: String		= "deutan";
		public static const TYPE_TRITAN: String		= "tritan";

		public static const NORMAL: String			= "normal vision";
		public static const PROTANOPY: String		= "protanopy";
		public static const PROTANOMALY: String		= "protanomaly";
		public static const DEUTERANOPY: String		= "deuteranopy";
		public static const DEUTERANOMALY: String	= "deuteranomaly";
		public static const TRITANOPY: String		= "tritanopy";
		public static const TRITANOMALY: String		= "tritanomaly";
		public static const ACHROMATOPSY: String	= "achromatopsy";
		public static const ACHROMATOMALY: String	= "achromatomaly";

		private static const GAMMA: Number = 2.2;
		private static const WX: Number = 0.312713;
		private static const WY: Number = 0.329016;
		private static const WZ: Number = 0.358271;
		
		private static const blind_dict: Dictionary = new Dictionary();
		private static const anomalyze_dict: Dictionary = new Dictionary();
		private static const monochrome_dict: Dictionary = new Dictionary();

		/**
		 * Converts <code>RGB</code> data a specific color deficiency.
		 * 
		 * @param rgb Data to be converted
		 * @param type Color deficiency typology
		 * @return Converted data
  		 */
		public static function convertColor( rgb: RGB, type: String ): RGB
		{
			var converted_rgb: RGB;
			switch( type )
			{
				case PROTANOPY:
					rgb = blind( rgb, TYPE_PROTAN );
					break;
				case PROTANOMALY:
					rgb = anomalyze( rgb, blind( rgb, TYPE_PROTAN ) );
					break;
				case DEUTERANOPY:
					rgb = blind( rgb, TYPE_DEUTAN );
					break;
				case DEUTERANOMALY:
					rgb = anomalyze( rgb, blind( rgb, TYPE_DEUTAN ) );
					break;
				case TRITANOPY:
					rgb = blind( rgb, TYPE_TRITAN );
					break;
				case TRITANOMALY:
					rgb = anomalyze( rgb, blind( rgb, TYPE_TRITAN ) );
					break;
				case ACHROMATOPSY:
					rgb = monochrome( rgb );
					break;
				case ACHROMATOPSY:
					rgb = anomalyze( rgb, monochrome( rgb ) );
					break;
				default:
					rgb = new RGB( rgb.red, rgb.green, rgb.blue );
					break;
			}
			return rgb;
		}

		/**
		 * Converts a color value to monochrome vision
		 * 
		 * @param rgb Color to be converted
		 * @return Converted color
		 */
		public static function monochrome( rgb:RGB ): RGB
		{
			if ( !monochrome_dict[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
			{
				var val: uint = Math.round( rgb.red * .299 + rgb.green * .587 + rgb.blue * .114 );
				monochrome_dict[ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new RGB( val, val, val );
			}
			return monochrome_dict[ rgb.red << 16 | rgb.green << 8 | rgb.blue ];
		}
		
		/**
		 * Converts a color value to severe color blindness
		 * 
		 * @param rgb Color to be converted
		 * @param type Color deficiency typology
		 * @return Converted color
		 */
		public static function blind( rgb: RGB, type: String ): RGB
		{
			if ( !blind_dict[ type ] )
				blind_dict[ type ] = new Dictionary();
			
			if ( !blind_dict[ type ][ rgb.red << 16 | rgb.green << 8 | rgb.blue ] )
			{
				var blind_am: Number = ( ( blind_map[ type ].aev - blind_map[ type ].abv ) / ( blind_map[ type ].aeu - blind_map[ type ].abu ) );
				var blind_ayi: Number = blind_map[ type ].abv - blind_map[ type ].abu * blind_am;
	
				var r: Number = Math.pow( rgb.red / 255, GAMMA );
				var g: Number = Math.pow( rgb.green / 255, GAMMA );
				var b: Number = Math.pow( rgb.blue / 255, GAMMA );
				
				var color: Object = new Object();
				color.x = ( 0.430574 * r + 0.341550 * g + 0.178325 * b );
				color.y = ( 0.222015 * r + 0.706655 * g + 0.071330 * b );
				color.z = ( 0.020183 * r + 0.129553 * g + 0.939180 * b );
				color.u = 0;
				color.v = 0;
				var sum_xyz: Number = color.x + color.y + color.z;
	
				if ( sum_xyz != 0 )
				{
					color.u = color.x / sum_xyz;
					color.v = color.y / sum_xyz;
				}
				
				var nx: Number = WX * color.y / WY;
				var nz: Number = WZ * color.y / WY;
				var clm: Number;
							
				if ( color.u < blind_map[ type ].cpu )
					clm = ( blind_map[ type ].cpv - color.v ) / ( blind_map[ type ].cpu - color.u );
				else
					clm = ( color.v - blind_map[ type ].cpv ) / ( color.u - blind_map[ type ].cpu );	
				
				var clyi: Number = color.v - color.u * clm;
	
				var d: Object = new Object();
				d.y = 0;
				d.u = ( blind_ayi - clyi ) / ( clm - blind_am );
				d.v = ( clm * d.u ) + clyi;
	
				var s: Object = new Object();
				s.x = d.u * color.y / d.v;
				s.y = color.y;
				s.z = ( 1 - ( d.u + d.v ) ) * color.y / d.v;
	
				s.r = ( 3.063218 * s.x - 1.393325 * s.y - 0.475802 * s.z);
				s.g = ( -0.969243 * s.x + 1.875966 * s.y + 0.041555 * s.z );
				s.b = ( 0.067871 * s.x - 0.228834 * s.y + 1.069251 * s.z );
	
				d.x = nx - s.x;
				d.z = nz - s.z;
				
				d.r = ( 3.063218 * d.x - 1.393325 * d.y - 0.475802 * d.z);
				d.g = ( -0.969243 * d.x + 1.875966 * d.y + 0.041555 * d.z );
				d.b = ( 0.067871 * d.x - 0.228834 * d.y + 1.069251 * d.z );
	
				var adjr: Number = d.r? ( ( s.r < 0 ? 0: 1 ) - s.r ) / d.r: 0;
				var adjg: Number = d.g? ( ( s.g < 0 ? 0: 1 ) - s.g ) / d.g: 0;
				var adjb: Number = d.b? ( ( s.b < 0 ? 0: 1 ) - s.b ) / d.b: 0;
	
				var adjust: Number = Math.max( ( ( adjr > 1 || adjr < 0 )? 0: adjr ), ( ( adjg > 1 || adjg < 0 )? 0: adjg ), ( ( adjb > 1 || adjb < 0 )? 0: adjb ) );
	
				s.r = s.r + ( adjust * d.r );
				s.g = s.g + ( adjust * d.g );
				s.b = s.b + ( adjust * d.b );
				
				blind_dict[ type ][ rgb.red << 16 | rgb.green << 8 | rgb.blue ] = new RGB( Math.round( getColorValue( s.r ) ),  Math.round( getColorValue( s.g ) ), Math.round( getColorValue( s.b ) ) );
			}

			return blind_dict[ type ][ rgb.red << 16 | rgb.green << 8 | rgb.blue ];
		}
		
		/**
		 * Converts a color value to mild severe color blindness
		 * 
		 * @param rgb1 Color to be converted
		 * @param rgb2 Severe color deficiency value of rgb1
		 * @return Converted color
		 */
		public static function anomalyze( rgb1: RGB, rgb2: RGB ): RGB
		{
			if ( !anomalyze_dict[ rgb1.red << 16 | rgb1.green << 8 | rgb1.blue ] )
				anomalyze_dict[ rgb1.red << 16 | rgb1.green << 8 | rgb1.blue ] = new Dictionary();

			if ( !anomalyze_dict[ rgb1.red << 16 | rgb1.green << 8 | rgb1.blue ][ rgb2.red << 16 | rgb2.green << 8 | rgb2.blue ] )
			{
				var v: Number = 1.75;
				var d: Number = v * 1 + 1;
				
				anomalyze_dict[ rgb1.red << 16 | rgb1.green << 8 | rgb1.blue ][ rgb2.red << 16 | rgb2.green << 8 | rgb2.blue ] = new RGB( ( v * rgb2.red + rgb1.red * 1 ) / d, ( v * rgb2.green + rgb1.green * 1 ) / d, ( v * rgb2.blue + rgb1.blue * 1 ) / d );
			}
			return anomalyze_dict[ rgb1.red << 16 | rgb1.green << 8 | rgb1.blue ][ rgb2.red << 16 | rgb2.green << 8 | rgb2.blue ];
		}
		
		/**
		 * @private
		 */
		private static function getColorValue( value:Number ): Number
		{
			return ( 255 * ( value <= 0 ? 0: value >= 1? 1: Math.pow( value, 1 / GAMMA ) ) );
		}
		
	}
}