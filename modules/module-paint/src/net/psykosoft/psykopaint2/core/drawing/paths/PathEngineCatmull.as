package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.geom.Point;

	public class PathEngineCatmull extends AbstractPathEngine
	{
		private var _lastPoint1 : SamplePoint;
		private var _lastPoint2 : SamplePoint;
		private var _lastX : Number;
		private var _lastY : Number;
		private var _lastPressure : Number;
		private var _squaredAccumulatedDistance : Number;
		
		private var _lastResultLastPoint : SamplePoint;
		
		private var _lastSegmentSpeed : Number = 0;
		
		private var _speed : Number = 0;
		
		private var _simplificationDistance : Number = 80;
		
		private var _speedFactor : Number = 0.02;
		
		
		public function PathEngineCatmull()
		{
			_minSamplesPerStep.intValue = 4;
			_outputStepSize.numberValue = 3;
			init();
		}
		
		override public function get type():int
		{
			return PathManager.ENGINE_TYPE_CATMULL;
		}
		
		override public function addFirstPoint( x:Number,y:Number, pressure:Number = -1, penButtonState:int = 0 ):void
		{
			_lastResultLastPoint = null;
			_lastPoint1 = null;
			_lastPoint2 = null;
			
			_lastX = x;
			_lastY = y;
			
			_lastSegmentSpeed = 0;
			_speed = 0;
			_squaredAccumulatedDistance = 0;
			
			_lastPressure = pressure;
			
			super.addFirstPoint(x,y, pressure, penButtonState);
			
		}


		override public function update(forceUpdate : Boolean = false) : Vector.<SamplePoint>
		{
			var result : Vector.<SamplePoint> = new Vector.<SamplePoint>();
		 
			if (forceUpdate || pointCount - _lastOutputIndex > _minSamplesPerStep.intValue || ( pointCount - _lastOutputIndex > 1 )) 
			{
				
				var rsq:Number = _outputStepSize.numberValue * _outputStepSize.numberValue;
				var currentSquaredDistance : Number = 0;
				
				var simplePath : PathEngineCatmull = clone(_lastOutputIndex, -1) as PathEngineCatmull;
				simplePath.simplify2(0, -1, _simplificationDistance);
				var p : SamplePoint = simplePath.getPointAt(-1);
				simplePath.addSamplePoint(p,true);
				var engine2 : IPathEngine = CatmullRomInterpolator.interpolate(simplePath, 0, -1);
				//PathInterpolator.interpolate( PathInterpolator.TYPE_CATMULLROM, simplePath, 0,-1 );
				var bs : int = _minSamplesPerStep.intValue >> 1;
				if (_lastPoint1 != null) {
					
					p = engine2.getPointAt(bs);
					var px:Number = p.x;
					var py:Number = p.y;
					var lp1x:Number = _lastPoint1.x;
					var lp1y:Number = _lastPoint1.y;
					var lp2x:Number = _lastPoint2.x;
					var lp2y:Number = _lastPoint2.y;
					var steps:int = 1 +  (Math.pow( px - lp1x, 2 ) + Math.pow( py - lp1y, 2 )) / (rsq * 0.25);
					var tstep:Number = 1 / steps;
					var t:Number = 0;
					for (var i : int = 0; i <= steps; i++) 
					{
						var ti : Number = 1 - t;
						var p2x : Number = ti * ti * lp1x + 2 * t * ti * lp2x + t * t * px;
						var p2y : Number = ti * ti * lp1y + 2 * t * ti * lp2y + t * t * py;
						var dx : Number = p2x - _lastX;
						var dy : Number = p2y - _lastY;
						var d : Number = dx * dx + dy * dy;
						_squaredAccumulatedDistance += d;
						currentSquaredDistance += d;
						if (_squaredAccumulatedDistance >= rsq) 
						{
							//TODO: this is probably missing vital information like pressure 
							result.push(PathManager.getSamplePoint(p2x, p2y));
							_squaredAccumulatedDistance -= rsq;
						}
						_lastX = p2x;
						_lastY = p2y;
						t += tstep;
					}
					
				}
				_lastPoint1 = engine2.getPointAt(engine2.pointCount - bs).getClone();
				_lastPoint2 = engine2.getPointAt(engine2.pointCount - 1).getClone();
				
				i = _lastOutputIndex > 0 ? bs : 0;
				var j : int = engine2.pointCount - ( _lastOutputIndex > 0 ? 2 * bs : bs);
				while (j > 0) {
					p = engine2.getPointAt(i);
					dx = p.x - _lastX;
					dy = p.y - _lastY;
					d = dx * dx + dy * dy;
					_squaredAccumulatedDistance += d;
					currentSquaredDistance += d;
					if (_squaredAccumulatedDistance >= rsq) {
						result.push(p);
						_squaredAccumulatedDistance -= rsq;
					}
					
					_lastX = p.x;
					_lastY = p.y;
					
					j--;
					i++;
				}
				
				PathManager.recyclePathEngine(engine2);
				PathManager.recyclePathEngine(simplePath);
				_lastOutputIndex =  pointCount - 1;
				
				if (result.length > 0) {
					/*
					var currentSegmentSpeed : Number = currentDistance;
					_lastDistance = currentDistance;
					*/
					var currentSegmentSpeed : Number = currentSquaredDistance;
					//_lastSquaredDistance = currentSquaredDistance;
					
					var speedDifference : Number = currentSegmentSpeed - _lastSegmentSpeed;
					_lastSegmentSpeed = currentSegmentSpeed;
					var speedDelta : Number = speedDifference / result.length * _speedFactor;
					
					if (_lastResultLastPoint == null) {
						_lastResultLastPoint = result[0];
					} else {
						result.unshift(_lastResultLastPoint);
					}
					for (i = 0; i < result.length - 1; i++) 
					{
						dx = result[int(i + 1)].x - _lastResultLastPoint.x;
						dy = result[int(i + 1)].y - _lastResultLastPoint.y;
						result[i].angle = Math.atan2(dy, dx);
						_lastResultLastPoint = result[i];
						result[i].speed = _speed;
						_speed += speedDelta;
					}
					
					_lastResultLastPoint = result[i];
					result.pop();
				}
			}
			return result;
		}
		
		public function simplify2( startIndex:int = 0, endIndex:int = -1, timeRadius:int = 1000, distanceThreshold:Number = 10 ):void
		{
			if ( endIndex == -1 ) endIndex = nextIndex - 1;
			if ( endIndex - startIndex < 2 ) return;
			
			
			var distanceLimit:Number = distanceThreshold * distanceThreshold;
			for ( var i:int = startIndex+1; i < endIndex; i++ )
			{
				var currentPoint:SamplePoint = sampledPoints[i];
				var sum_x:Number = currentPoint.x;
				var sum_y:Number = currentPoint.y;
				
				var sum_c:Number = 1;
				for ( var j:int = i+1; j <= endIndex; j++ )
				{
					var testPoint:SamplePoint = sampledPoints[j];
					
					var dx:Number = sum_x / sum_c - testPoint.x;
					var dy:Number = sum_y / sum_c - testPoint.y;
					if ( dx*dx+dy*dy < distanceLimit )
					{
						sum_x += testPoint.x;
						sum_y += testPoint.y;
						
						sum_c++;
					} else {
						break;
					}
					
					
				}	
				if ( sum_c > 1 )
				{
					if ( i > startIndex )
					{
						if ( j-1 < endIndex )
						{
							
							sum_c = sum_x = sum_y = 0;
							
							for ( var k:int = i; k < j; k++ )
							{
								var dot:Number = 2;
								if ( k > 0 && k < nextIndex - 1 )
								{
									var dx1:Number = sampledPoints[k].x - sampledPoints[k-1].x;
									var dy1:Number = sampledPoints[k].y - sampledPoints[k-1].y;
									var d1:Number = Math.sqrt( dx1*dx1 + dy1*dy1);
									if ( d1 != 0 )
									{
										dx1 /= d1;
										dy1 /= d1;
									}
									var dx2:Number = sampledPoints[k].x - sampledPoints[k+1].x;
									var dy2:Number = sampledPoints[k].y - sampledPoints[k+1].y;
									var d2:Number = Math.sqrt( dx2*dx2 + dy2*dy2);
									if ( d2 != 0 )
									{
										dx2 /= d2;
										dy2 /= d2;
									}
									dot = 2 + dx1 * dx2 + dy1 * dy2;
								}
								
								sum_c += 1;
								sum_x += sampledPoints[k].x;
								sum_y += sampledPoints[k].y;
								
							}
							currentPoint.x = sum_x / sum_c;
							currentPoint.y = sum_y / sum_c;
							
						} else {
							currentPoint.x = sampledPoints[j-1].x;
							currentPoint.y = sampledPoints[j-1].y;
							
						}
					} 
					
					for ( k = i+1; k < j; k++ )
					{
						PathManager.recycleSamplePoint(sampledPoints[k]);
						//currentPoint.next = 
					}
					var rmv:int = j-(i+1);
					sampledPoints.splice(i+1,rmv);
					endIndex -= rmv;
					nextIndex -= rmv;
				}
			}
			
		}
	}
}