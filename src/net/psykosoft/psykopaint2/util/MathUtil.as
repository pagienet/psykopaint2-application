package net.psykosoft.psykopaint2.util
{

	public class MathUtil
	{
		public static function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}
	}
}
