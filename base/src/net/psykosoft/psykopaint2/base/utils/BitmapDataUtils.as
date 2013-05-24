package net.psykosoft.psykopaint2.base.utils
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class BitmapDataUtils
	{
		public function BitmapDataUtils()
		{
		}
		
		static public function getLegalBitmapData( map:BitmapData, forceClone:Boolean = false, maxDimension:int = 2048 ):BitmapData
		{
			if ( map.width <= maxDimension && map.height <= maxDimension ) return forceClone ? map.clone() : map;
			
			var scale:Number = Math.max( maxDimension / map.width, maxDimension / map.height );
			if ( map.width * scale > maxDimension || map.height * scale > maxDimension )
				scale = Math.min( maxDimension/ map.width, maxDimension / map.height );
				
			var result:BitmapData = new BitmapData( map.width * scale, map.height * scale, true, 0 );
			result.draw( map, new Matrix(scale,0,0,scale),null,"normal",null,true );
			return result;
		}
	}
}