package net.psykosoft.psykopaint2.core.drawing.paths
{
	
	public class PathEngineBasic extends AbstractPathEngine
	{
		private var _lastX:Number;
		private var _lastY:Number;
		private var _accumulatedDistance:Number;
		private var _lastSpeed:Number;
		private var _lastAngle:Number;
		private var _lastPressure:Number;
		
		
		public function PathEngineBasic()
		{
			super();
			sendTaps = true;
		}
		
		override public function get type():int
		{
			return PathManager.ENGINE_TYPE_BASIC;
		}
		
		
		override public function addFirstPoint( x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0 ):void
		{
			_lastX = x;
			_lastY =y;
			_accumulatedDistance = 0;
			_lastSpeed = 0;
			_lastAngle = NaN;
			_lastPressure = pressure;
			super.addFirstPoint(x,y,pressure,penButtonState);
		}
		
		override public function update(forceUpdate : Boolean = false) : Vector.<SamplePoint>
		{
			
			var result : Vector.<SamplePoint> = new Vector.<SamplePoint>();
			if ( !forceUpdate && (pointCount - _lastOutputIndex < _minSamplesPerStep.intValue)) return result;
			
			if ( isNaN(_lastAngle) && nextIndex > 1 ) _lastAngle = Math.atan2(sampledPoints[1].y - sampledPoints[0].y, sampledPoints[1].x - sampledPoints[0].x);
			
			if ( _lastPressure == -1 && sampledPoints[_lastOutputIndex].pressure != -1 ) _lastPressure = 0;
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
					
					if ( _accumulatedDistance >= outputStep )
					{
						
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
						
					//	var stepSize:Number = outputStep / _accumulatedDistance;
						
						var stepSize:Number = (d -( _accumulatedDistance - outputStep )) / d;
						var ds:Number = (speed - _lastSpeed) * stepSize;
						var dp:Number = (target.pressure - _lastPressure)  * stepSize;
						
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
						
						var pb:int = target.penButtonState;	
						var step:Number = stepSize;
						angle = _lastAngle;
						
						var ddx:Number = dx * stepSize / d;
						var ddy:Number = dy * stepSize / d;
						_lastX += ddx;
						_lastY += ddy;
						_lastSpeed += ds;
						_lastAngle = angle + da *(-Math.pow(2, -10 * step) + 1);
						_lastPressure += dp;
						step+=stepSize;
						result.push( PathManager.getSamplePoint( _lastX, _lastY, _lastSpeed,0, _lastAngle, _lastPressure, pb ) );
						_accumulatedDistance-=outputStep;
						
						if ( _accumulatedDistance > outputStep )
						{
							stepSize = outputStep / _accumulatedDistance;
							ds = (speed - _lastSpeed) * stepSize;
							dp = (target.pressure - _lastPressure)  * stepSize;
							d /= outputStep;
							dx /= d;
							dy /= d;
							while ( _accumulatedDistance > outputStep )
							{
								_lastX += dx;
								_lastY += dy;
								_lastSpeed += ds;
								
								_lastAngle = angle + da *(-Math.pow(2, -10 * step) + 1);
								_lastPressure += dp;
								step+=stepSize;
								result.push( PathManager.getSamplePoint( _lastX, _lastY, _lastSpeed,0, _lastAngle, _lastPressure, pb ) );
								_accumulatedDistance-=outputStep;
							}
						}
						_lastAngle %= 2 * pi;
						
					} else {
						_lastAngle = angle; 
						_lastPressure = target.pressure;
						_lastX += dx;
						_lastY += dy;
						_lastSpeed = _accumulatedDistance / outputStep;
						
					}
						
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