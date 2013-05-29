package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.geom.Point;
	
	public final class SamplePoint extends Point
	{
		public var speed:Number;
		public var angle:Number;
		public var colorsRGBA:Vector.<Number>;
		public var normalX:Number;
		public var normalY:Number;
		public var size:Number;
		
		public function SamplePoint( x:Number = 0, y:Number = 0, speed:Number = 0, size:Number = 0, angle:Number = 0, colors:Vector.<Number> = null)
		{
			colorsRGBA = new Vector.<Number>();
			resetData(x, y, speed, size, angle, colors);
		}
		
		public function resetData(x:Number = 0, y:Number = 0, speed:Number = 0, size:Number = 0, angle:Number = 0, colors:Vector.<Number> = null):SamplePoint
		{
			this.x = x;
			this.y = y;
			this.speed = speed;
			this.angle = angle;
			this.size = size;
			
			if ( colors == null )
			{
				for ( var i:int = 0; i < 16; i++ )
				{
					colorsRGBA[i] = 0;
				}
			} else {
				for ( i = 0; i < 16; i++ )
				{
					colorsRGBA[i] = colors[i];
				}
			}
			return this;
		}
		
		public function normalizeXY( scaleW:Number, scaleH:Number ):void
		{
			normalX = x * scaleW - 1.0;
			normalY = -(y * scaleH - 1.0);
		}
		
		public function getClone():SamplePoint
		{
			return PathManager.getSamplePoint(this,speed,size, angle,colorsRGBA);
		}
		
		public function squaredDistance( p:SamplePoint ):Number
		{
			var d:Number;
			return ( ( d = x - p.x ) * d + ( d = y - p.y ) * d );
		}
		
		public function distanceToLine(p1:SamplePoint, p2:SamplePoint ):Number
		{
			var dx:Number, dy:Number;
			if ( p1.equals(p2) )
			{
				return Point.distance(this,p1);
			} 
			var area:Number = Math.abs( 0.5 * ( p1.x * p2.y + p2.x * y + x * p1.y - p2.x * p1.y - x * p2.y - p1.x * y ));
			return area / Point.distance(p1,p2) * 2;
		}
		
		
		
		
	}
}