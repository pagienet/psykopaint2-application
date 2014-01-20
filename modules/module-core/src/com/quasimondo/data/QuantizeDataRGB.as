package com.quasimondo.data
{
	import flash.utils.Dictionary;
	
	final public class QuantizeDataRGB
	{
		
		public var r:Number;
		public var g:Number;
		public var b:Number;
		
		private var radius:Number;
		private var weight:Number;
		
		private var distanceCache:Dictionary;
		
		public function QuantizeDataRGB( rgb:int, radius:Number = 1, weight:Number = 1 )
		{
			r = ( rgb >> 8 ) & 0xff;
			g = ( rgb >> 16 ) & 0xff;
			b = (rgb >>> 24) & 0xff;
			
			this.radius = radius;
			this.weight = weight;
			clearDistanceCache();
		}
		
		public function get rgb():int
		{
			var ri:int = int( r + 0.5  );
			var gi:int = int( g + 0.5  );
			var bi:int = int( b + 0.5  );
			
			if ( ri < 0 ) ri = 0;
			if ( ri > 255 ) ri = 255;
			if ( gi < 0 ) gi = 0;
			if ( gi > 255 ) gi = 255;
			if ( bi < 0 ) bi = 0;
			if ( bi > 255 ) bi = 255;
			
			return ri << 16 | gi << 8 | bi;
		}
		

		public function getDistanceTo( data:QuantizeDataRGB ):Number
		{
			var dr:Number = r - data.r;
			var dg:Number = g - data.g;
			var db:Number = b - data.b;
			
			var d:Number = distanceCache[ data ] =  dr * dr + dg * dg + db * db;
			data.setDistanceTo( this, d );
			return d;
		}
		
		public function setDistanceTo( data:QuantizeDataRGB, distance:Number ):void
		{
			 distanceCache[ data ] = distance;
		}
		
		public function isWithinRadius( data:QuantizeDataRGB, useCache:Boolean = true ):Boolean
		{
			if ( !useCache || distanceCache[ data ] == null )
			{
				 getDistanceTo( data );
			}
			
			return ( distanceCache[ data ] <= radius );
		}
		
		public function merge( data:QuantizeDataRGB ):void
		{
			var dataWeight:Number = data.getWeight();
			var newWeight:Number = weight + dataWeight;
			r = ( r * weight + data.r * dataWeight ) / newWeight;
			g = ( g * weight + data.g * dataWeight ) / newWeight;
			b = ( b * weight + data.b * dataWeight ) / newWeight;
			weight = newWeight;
			
			//radius += dataWeight;
			radius = dataWeight * dataWeight;
		}
		
		public function getRadius():Number
		{
			return radius;
		}
		
		public function getWeight():Number
		{
			return weight;
		}
		
		public function clearDistanceCache():void
		{
			distanceCache = new Dictionary();
		}
	}
}