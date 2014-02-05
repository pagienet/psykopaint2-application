package com.quasimondo.color.utils
{
	import com.quasimondo.color.colorspace.HSL;
	import com.quasimondo.color.colorspace.IColorSpace;

	public class ColorHarmony
	{
		
		public function ColorHarmony()
		{
		}
		
		/**
		 Returns an Array of two colors. The first color in the Array
		 will be the color passed in. The second will be the
		 complementary color of the color provided
		 **/
		public static function getComplementary( color:IColorSpace ):Vector.<uint>
		{
			
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
				
			hsl.hue += 180;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			return result;
		}
			
				
		/**
			Returns an Array of three colors. The first color in the Array
		will be the color passed in. The second two will be split
		complementary colors.
		**/
		public static function getSplit(color:IColorSpace, offset:Number = 30 ):Vector.<uint>
		{
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
			
			hsl.hue += 180 + offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			hsl.hue -= 2 * offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			return result;
		}	
				
			/**
				Returns an Array of five colors. The first color in the Array
			will be the color passed in. The remaining four will be
			analogous colors two in either direction from the initially
			provided color.
			**/
		public static function getAnalogous(color:IColorSpace, offset:Number = 10 ):Vector.<uint> 
		{
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
				
			hsl.hue += offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			hsl.hue += offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			hsl.hue -= 3 * offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			hsl.hue -= offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			return result;
		}
				
		/**
			Returns an Array of three colors. The first color in the Array
		will be the color passed in. The second two will be equidistant
		from the start color and each other.
		**/
		public static function getTriad(color:IColorSpace ):Vector.<uint> 
		{
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
				
			hsl.hue += 120;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			hsl.hue += 120;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			return result;
		}
				
		/**
			Returns an Array of four colors. The first color in the Array
		will be the color passed in. The remaining three colors are
		equidistant offsets from the starting color and each other.
		**/
		public static function getTetrad(color:IColorSpace, offset:Number = 60 ):Vector.<uint> 
		{
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
			
			hsl.hue += offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );	
			hsl.hue += 180;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			hsl.hue -= offset;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );		
			return result;	
		}
				
		/**
			Returns an Array of four colors. The first color in the Array
		will be the color passed in. The remaining three colors are
		equidistant offsets from the starting color and each other.
		**/
		public static function getSquare(color:IColorSpace ):Vector.<uint> 
		{
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = Vector.<uint>([ColorConverter.HSLtoARGB(hsl).alphaColor]);
					
			hsl.hue += 90;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			hsl.hue += 90;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			hsl.hue += 90;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			return result;	
		}
				
		/**
			Calculates lightness offsets resulting in a monochromatic Array
		of values.
		**/
		public static function getMonochrome(color:IColorSpace, count:int = 3 ):Vector.<uint> 
		{
			if ( count < 2 ) count = 2;
			
			var step:Number = 100 / (count - 1);
			var hsl:HSL = ColorConverter.AnyToHSL(color);
			var result:Vector.<uint> = new Vector.<uint>();
				
			var i:Number = 0;
			while ( i < 100 )
			{
				hsl.lightness = i;
				result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
				i+= step;
			}
			hsl.lightness = 100;
			result.push(ColorConverter.HSLtoARGB(hsl).alphaColor );
			
			return result;
		}
		
		/**
			Creates an Array of similar colors. Returned Array is prepended
		with the color provided followed a number of colors decided
		by count
		**/
		public static function getRange(color:IColorSpace, offset_hue:Number = 15, count_hue:int = 3, offset_saturation:Number = 15, count_saturation:int = 3, offset_lightness:Number = 15, count_lightness:int = 3 ):Vector.<uint>
		{
			if ( count_hue < 1 ) count_hue = 1;
			if ( count_saturation < 1 ) count_saturation = 1;
			if ( count_lightness < 1 ) count_lightness = 1;
			var result:Vector.<uint> = new Vector.<uint>();
			var hsl_base:HSL = ColorConverter.AnyToHSL(color);
			
			for ( var i:int = 0; i < count_hue; i++ )
			{
				var hsl:HSL = new HSL();
				hsl.hue = hsl_base.hue - count_hue * offset_hue * 0.5 + i * offset_hue;
				for ( var j:int = 0; j < count_saturation; j++ )
				{
					hsl.saturation = hsl_base.saturation - count_saturation * offset_saturation * 0.5 + j * offset_saturation;
					for ( var k:int = 0; k < count_lightness; k++ )
					{
						hsl.lightness = hsl_base.lightness- count_lightness * offset_lightness * 0.5 + k * offset_lightness;
						var c:uint = ColorConverter.HSLtoARGB(hsl).alphaColor;
						if ( result.indexOf(c) == -1 ) result.push(c);
					}	
				}
			}
			
			return result;
		};
		
		
		/**
		 Creates Gradient of black to white which passes through the chosen color
		 **/
		public static function getGradient(color:IColorSpace, count:int):Vector.<uint>
		{
			
			var result:Vector.<uint> = new Vector.<uint>();
			var hsl_base:HSL = ColorConverter.AnyToHSL(color);
			var c:uint, t:Number;
			for ( var i:int = 0; i < count / 2; i++ )
			{
				var hsl:HSL = new HSL();
				hsl.hue = hsl_base.hue ;
				t = i / (count / 2);
				
				hsl.saturation = hsl_base.saturation * t;
				hsl.lightness = hsl_base.lightness * t;
				c = ColorConverter.HSLtoARGB(hsl).alphaColor;
				result.push(c);
			}
			for ( i = 0; i < count / 2; i++ )
			{
				hsl = new HSL();
				hsl.hue = hsl_base.hue ;
				t = (i+1) / (count / 2);
				
				hsl.saturation = ( 1-t) * hsl_base.saturation;
				hsl.lightness = 99 * t + ( 1-t) * hsl_base.lightness;
				c = ColorConverter.HSLtoARGB(hsl).alphaColor;
				result.push(c);
			}
			
			return result;
		};		
	}
}