package net.psykosoft.psykopaint2.util
{

	public class MathUtil
	{
		public static function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}

		public static function randRnd( min:Number, max:Number ):int {
			return Math.round( rand( min, max ) );
		}
	}
}
