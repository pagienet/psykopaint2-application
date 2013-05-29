package net.psykosoft.psykopaint2.core.utils
{
	public class TextureUtils
	{
		public static function getBestPowerOf2(value : uint) : Number
		{
			var p : uint = 1;

			while (p < value)
				p <<= 1;

			if (p > 2048) p = 2048;

			return p;
		}
	}
}
