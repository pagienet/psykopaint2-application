package net.psykosoft.psykopaint2.core.drawing.paths
{
	import com.quasimondo.geom.Vector2;
	
	import flash.geom.Point;
	
	public final class SamplePoint extends Point
	{
		public var speed:Number;
		public var angle:Number;
		public var colorsRGBA:Vector.<Number>;
		public var bumpFactors:Vector.<Number>;
		public var normalX:Number;
		public var normalY:Number;
		public var size:Number;
		public var pressure:Number;
		public var penButtonState:int;
		public var first:Boolean;
		public var curvature:Number;
		
		public function SamplePoint( x:Number = 0, y:Number = 0, speed:Number = 0, size:Number = 0, angle:Number = 0, curvature:Number = 0, pressure:Number = -1, penButtonState:int = 0, colors:Vector.<Number> = null, bumpFactors:Vector.<Number> = null, first:Boolean = false)
		{
			this.colorsRGBA = new Vector.<Number>(16,true);
			this.bumpFactors = new Vector.<Number>(16,true);
			resetData(x, y, speed, size, angle, curvature, pressure, penButtonState, colors,bumpFactors,first);
		}
		
		public function resetData(x:Number = 0, y:Number = 0, speed:Number = 0, size:Number = 0, angle:Number = 0, curvature:Number = 0, pressure:Number = -1, penButtonState:int = 0, colors:Vector.<Number> = null, bumpFactors:Vector.<Number> = null, first:Boolean = false):SamplePoint
		{
			this.x = x;
			this.y = y;
			this.speed = speed;
			this.angle = angle;
			this.curvature = curvature;
			this.size = size;
			this.pressure = pressure;
			this.penButtonState = penButtonState;
			this.first = first;
			var i:int;
			var rgba:Vector.<Number> = this.colorsRGBA;
			if ( colors == null )
			{
				for ( i = 0; i < 16; i++ )
				{
					rgba[i] = 0;
				}
			} else {
				for ( i = 0; i < 16; i++ )
				{
					rgba[i] = colors[i];
				}
			}
			
			var bf:Vector.<Number> = this.bumpFactors;
			if ( bumpFactors == null )
			{
				for ( i = 0; i < 16; i++ )
				{
					bf[i] = 0;
				}
			} else {
				for ( i = 0; i < 16; i++ )
				{
					bf[i] = bumpFactors[i];
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
			return PathManager.getSamplePoint(x,y,speed,size, angle, curvature, pressure, penButtonState, colorsRGBA, bumpFactors, first);
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