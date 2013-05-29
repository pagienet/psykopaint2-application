package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.geom.Point;
	
	public class PathEngineBasic extends AbstractPathEngine
	{
		private var _lastX:Number;
		private var _lastY:Number;
		private var _accumulatedDistance:Number;
		private var _lastSpeed:Number;
		private var _lastAngle:Number;
		
		public function PathEngineBasic()
		{
			super();
			sendTaps = true;
		}
		
		override public function get type():int
		{
			return PathManager.ENGINE_TYPE_BASIC;
		}
		
		
		override public function addFirstPoint( p:Point ):void
		{
			_lastX = p.x;
			_lastY = p.y;
			_accumulatedDistance = 0;
			_lastSpeed = 0;
			_lastAngle = NaN;
			super.addFirstPoint(p);
		}
		
		override public function update(forceUpdate : Boolean = false) : Vector.<SamplePoint>
		{
			
			var result : Vector.<SamplePoint> = new Vector.<SamplePoint>();
			if ( !forceUpdate && (pointCount - _lastOutputIndex < _minSamplesPerStep.intValue)) return result;
			
			if ( isNaN(_lastAngle) && nextIndex > 1 ) _lastAngle = Math.atan2(sampledPoints[1].y - sampledPoints[0].y, sampledPoints[1].x - sampledPoints[0].x);
			var pi:Number = Math.PI;
			var outputStep:Number = _outputStepSize.numberValue;
			for ( var i:int = _lastOutputIndex; i < nextIndex; i++ )
			{
				var target:SamplePoint = sampledPoints[i];
				var dx:Number = target.x - _lastX;
				var dy:Number = target.y - _lastY;
				var d:Number = dx*dx+dy*dy;
				if ( d > 0 )
				{
					d = Math.sqrt(d);
					
					var angle:Number = Math.atan2( dy,dx);
					
					_accumulatedDistance += d;
					
					var speed:Number = _accumulatedDistance / outputStep;
					
					if ( _lastSpeed > 0 )
					{
						if ( speed > 2 * _lastSpeed )
						{
							speed = 2 * _lastSpeed
						} else if ( speed < 0.5 *_lastSpeed)
						{
							speed = 0.5 * _lastSpeed
						}
					}	
						
					var ds:Number = (speed - _lastSpeed) * ( outputStep / _accumulatedDistance);
					var da:Number = (angle -_lastAngle);
					if ( da < -pi )
					{
						da += 2 * pi;
					} else if ( da > pi )
					{
						da -=pi * 2;
					}
					if ( da > pi * 0.5 || da < -pi * 0.5 )
					{
						_lastAngle = angle;
						da = 0;
					}
					
					var stepSize:Number = outputStep / _accumulatedDistance;
					var step:Number = stepSize;
					angle = _lastAngle;
					d /= outputStep;
					dx /= d;
					dy /= d;
					while ( _accumulatedDistance > outputStep )
					{
						_lastX += dx;
						_lastY += dy;
						_lastSpeed += ds;
						
						_lastAngle = angle + da *(-Math.pow(2, -10 * step) + 1);
						step+=stepSize;
						result.push( PathManager.getSamplePointXY( _lastX, _lastY, _lastSpeed * 0.05,0, _lastAngle ) );
						_accumulatedDistance-=outputStep;
					}
					
					_lastAngle %= 2 * pi;
				}
			}
			
			if ( forceUpdate && result.length == 0 && _accumulatedDistance == 0 )
			{
				result.push( sampledPoints[i-1].getClone()  );
			}
			
			_lastOutputIndex = nextIndex;
		
			return result;
		}
		
	}
}