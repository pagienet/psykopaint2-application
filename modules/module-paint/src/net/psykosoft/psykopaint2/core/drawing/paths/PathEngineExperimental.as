package net.psykosoft.psykopaint2.core.drawing.paths
{
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	
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
		
		override public function update(result:Vector.<SamplePoint>, forceUpdate : Boolean = false) : void
		{
			if ( pointCount < 3 ) return;
			
			var speedSmoothingFactor:Number = _speedSmoothing.numberValue;
			var stepFactor:Number = _outputStepSize.numberValue;
			var speedCorrection:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 0.5 : 1;
			var first:Boolean = false;
			if ( p1 == null )
			{
				p1 = sampledPoints[0];
				first = p1.first;
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
				if ( speed1 > 0 )
				{
					var ts:Number = stepFactor / speed1;
					if ( ts > 0.5 ) ts = 0.5;
					for ( var t:Number = 0; t < 0.5; t+= ts )
					{
						var ti: Number = 1-t;
						var ti2:Number = ti*ti;
						var tit:Number = ti*t*2;
						var tt:Number = t*t;
						var angle:Number = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
						
						var speed:Number = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
						lastPointSpeed = ((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed );
						var p:SamplePoint = PathManager.getSamplePoint( ti2*p1x+tit*cx+tt*p2x, 
																		ti2*p1y+tit*cy+tt*p2y,
																		lastPointSpeed * speedCorrection,
																		0,
																		angle,
																		ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
																		p1.penButtonState
																		);
						
						//lastPointSpeed = speed;
						result.push(p );
					}
					p1 = result[result.length-1];
					c = p2
					lastSpeed = speed1;
					_lastOutputIndex = 3;
				} else {
					_lastOutputIndex = 1;
					p1 = sampledPoints[1];
					c  = sampledPoints[2];
				}
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
				if ( speed1 > 0 )
				{
					
					ts = stepFactor / speed1;
					if ( ts > 0.25 ) ts = 0.25;
					
					for ( t = 0; t < 0.5; t+=ts )
					{
						ti = 1-t;
						ti2 = ti*ti;
						tit = ti*t*2;
						tt = t*t;
						angle = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
						speed = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
						lastPointSpeed  = ((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed );
						p = PathManager.getSamplePoint( 
							ti2*p1x+tit*cx+tt*p2x, 
							ti2*p1y+tit*cy+tt*p2y,
							lastPointSpeed * speedCorrection,
							0,
							angle,
							ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
							p1.penButtonState);
						
						//lastPointSpeed  = speed
						result.push( p);
					}
					
					PathManager.recycleSamplePoint(p1);
					p1 =  result[result.length-1];
					PathManager.recycleSamplePoint(c);
					c = p2
					lastSpeed = speed1;	
				} else {
					p1 = c;
					c = p2;
				}
			}
			
			p1 = p1.getClone();
			c = c.getClone();
			
			_lastOutputIndex = nextIndex;
		
			if ( forceUpdate )
			{
				if ( isNaN(ts) ) ts = 0.25;
				for ( t = 0.5; t < 1; t+=ts )
				{
					ti = 1-t;
					ti2 = ti*ti;
					tit = ti*t*2;
					tt = t*t;
					angle = Math.atan2( cy - p1y + t * ( p1y - 2 * cy + p2y), cx - p1x + t * (p1x - 2 * cx + p2x));
					speed = 0.4 * (ti2*lastSpeed+tit*speed1+tt*speed2);
					lastPointSpeed  = ((1-speedSmoothingFactor) * speed + speedSmoothingFactor * lastPointSpeed );
					p = PathManager.getSamplePoint( ti2*p1x+tit*cx+tt*p2x, 
						ti2*p1y+tit*cy+tt*p2y,
						lastPointSpeed * speedCorrection,
						0,
						angle,
						ti2*p1.pressure+tit*c.pressure+tt*p2.pressure,
						0);
					//lastPointSpeed  = speed
					result.push( p);
				}
				
			}
			
			if ( first && result.length > 0 )
			{
				result[0].first = true;
			}
		}
	}
}