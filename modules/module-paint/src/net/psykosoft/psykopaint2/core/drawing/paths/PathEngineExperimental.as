package net.psykosoft.psykopaint2.core.drawing.paths
{
	
	public class PathEngineExperimental extends AbstractPathEngine
	{
		private var p1:SamplePoint;
		private var p2:SamplePoint;
		private var c:SamplePoint;
		private var lastSpeed:Number;
		private var speed2:Number;
		private var lastPointSpeed:Number;
		
		public function PathEngineExperimental()
		{
			super();
			sendTaps = true;
		}
		
		override public function get type():int
		{
			return PathManager.ENGINE_TYPE_EXPERIMENTAL;
		}
		
		
		override public function addFirstPoint( x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0 ):void
		{
			super.addFirstPoint(x,y,pressure,penButtonState);
			p1 = null;
			p2 = null;
			c = null;
			lastSpeed = 0;
			lastPointSpeed = 0;
		}
		
		override public function update(forceUpdate : Boolean = false) : Vector.<SamplePoint>
		{
			
			var result : Vector.<SamplePoint> = new Vector.<SamplePoint>();
			if ( pointCount < 3 ) return result;
			
			var speedSmoothingFactor:Number = _speedSmoothing.numberValue;
			
			
			if ( p1 == null )
			{
				p1 = sampledPoints[0];
				c = sampledPoints[1];
				p2 = sampledPoints[2];
				var p1x:Number = p1.x;
				var p1y:Number = p1.y;
				var cx:Number = c.x;
				var cy:Number = c.y;
				var p2x:Number = p2.x;
				var p2y:Number = p2.y;
				
				var speed1:Number = Math.sqrt(p1.squaredDistance(c));
				
				speed2 = Math.sqrt(p2.squaredDistance(c));
				for ( var t:Number = 0; t < 0.5; t+= 0.02 )
				{
					var ti: Number = 1-t;
					var ti2:Number = ti*ti;
					var tit:Number = ti*t*2;
					var tt:Number = t*t;
					var angle:Number = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
					
					var speed:Number = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
					
					var p:SamplePoint = PathManager.getSamplePoint( ti2*p1x+tit*cx+tt*p2x, 
																	ti2*p1y+tit*cy+tt*p2y,
																	((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed ),
																	ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
																   angle);
					
					lastPointSpeed = speed;
					result.push(p );
				}
				p1 = result[result.length-1];
				c = p2
				lastSpeed = speed1;
				_lastOutputIndex = 3
			}
			
			for ( var i:int = _lastOutputIndex; i < nextIndex; i++ )
			{
				p2 = sampledPoints[i];
				speed1 = speed2;
				speed2 = Math.sqrt(p2.squaredDistance(c));
				p1x = p1.x;
				p1y = p1.y;
				cx = c.x;
				cy = c.y;
				p2x = p2.x;
				p2y = p2.y;
				
				for ( t = 0; t < 0.5; t+=0.02 )
				{
					ti = 1-t;
					ti2 = ti*ti;
					tit = ti*t*2;
					tt = t*t;
					angle = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
					speed = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
					
				 	p = PathManager.getSamplePoint( ti2*p1x+tit*cx+tt*p2x, 
						ti2*p1y+tit*cy+tt*p2y,
						((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed ),
						ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
						angle);
					
					lastPointSpeed  = speed
					result.push( p);
				}
				p1 =  result[result.length-1];
				c = p2
				lastSpeed = speed1;	
			}
			p1 = p1.getClone();
			c = c.getClone();
			_lastOutputIndex = nextIndex;
		
			if ( forceUpdate )
			{
				for ( t = 0.5; t < 1; t+=0.02 )
				{
					ti = 1-t;
					ti2 = ti*ti;
					tit = ti*t*2;
					tt = t*t;
					angle = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
					speed = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
					
					p = PathManager.getSamplePoint( ti2*p1x+tit*cx+tt*p2x, 
						ti2*p1y+tit*cy+tt*p2y,
						((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed ),
						ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
						angle);
					lastPointSpeed  = speed
					result.push( p);
				}
				
			}
			
			
			return result;
		}
		
		/*
		private function computeBezierPoints(
			VertexRec vertices[], int numPoints,
			double b0x, double b0y, 
			double b1x, double b1y, 
			double b2x, double b2y, 
			double b3x, double b3y
		) 
		{
			double ax, ay, bx, by, cx, cy, dx, dy;
			int numSteps, i;
			double h;
			double pointX, pointY;
			double firstFDX, firstFDY;
			double secondFDX, secondFDY;
			double thirdFDX, thirdFDY;
			
			assert(vertices != NULL);
			assert(numPoints >= 2);
			
			
			ax = -b0x + b3x;
			ay = -b0y + b3y;
			
			bx = 3 * b0x -3 * b1x;
			by = 3 * b0y -3 * b1y;
			
			dx = b0x;
			dy = b0y;
			
			
			
			numSteps = numPoints - 1;        //    arbitrary choice
			h = 1.0 / (double) numSteps;    //    compute our step size
			
			
			
			pointX = dx;
			pointY = dy;
			
			firstFDX = ax * (h * h * h) + bx * (h * h) - bx * h;
			firstFDY = ay * (h * h * h) + by * (h * h) - by * h;
			
			secondFDX = 6 * ax * (h * h * h) + 2 * bx * (h * h);
			secondFDY = 6 * ay * (h * h * h) + 2 * by * (h * h);
			
			thirdFDX = 6 * ax * (h * h * h);
			thirdFDY = 6 * ay * (h * h * h);    
			
			
			
			vertices[0].x = (int)pointX;
			vertices[0].y = (int)pointY;
			
			for (i = 0; i < numSteps; i++) {
				
				pointX += firstFDX;
				pointY += firstFDY;
				
				firstFDX += secondFDX;
				firstFDY += secondFDY;
				
				secondFDX += thirdFDX;
				secondFDY += thirdFDY;
				
				vertices[i + 1].x = (int)pointX;
				vertices[i + 1].y = (int)pointY;
				
			}
		}
		*/
		
	}
}