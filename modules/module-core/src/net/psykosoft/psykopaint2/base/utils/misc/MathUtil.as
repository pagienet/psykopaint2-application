package net.psykosoft.psykopaint2.base.utils.misc
{

	public class MathUtil
	{
		private static const applyArray:Array = [0,0,1,1];
		
		public static function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}

		public static function randRnd( min:Number, max:Number ):int {
			return Math.round( rand( min, max ) );
		}
		
		public static function mapNormalizedNumber( value:Number, easingFunction:Function ):Number
		{
			applyArray[0] = value;
			return easingFunction.apply( null, applyArray);
		}
		
		public static function mapNormalizedToRange( value:Number, min:Number, max:Number ):Number
		{
			return min + value * ( max - min);
		}
	}
}
