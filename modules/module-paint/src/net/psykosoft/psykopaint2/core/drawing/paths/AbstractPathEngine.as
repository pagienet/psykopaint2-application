package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.display.Graphics;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;

	public class AbstractPathEngine implements IPathEngine
	{
		protected var _sampledPoints:Vector.<SamplePoint>;
		protected var nextIndex:int;
		protected var _lastOutputIndex : int;
		
		protected var _minSamplesPerStep : PsykoParameter;
		protected var _outputStepSize:PsykoParameter;
		protected var _sendTaps:Boolean = false;
		protected var _parameters:Vector.<PsykoParameter>;
		
		public function AbstractPathEngine()
		{
			init();
		}
		
		protected function init():void
		{
			_sampledPoints = new Vector.<SamplePoint>();
			nextIndex = 0;
			_minSamplesPerStep = new PsykoParameter( PsykoParameter.IntParameter,"Minimum Samples Per Step",1,1,10);
			_outputStepSize = new PsykoParameter( PsykoParameter.NumberParameter,"Output Step Size",3,0.05,200);
			_parameters = new Vector.<PsykoParameter>();
			_parameters.push(_minSamplesPerStep,_outputStepSize);
		}
		
		public function get type():int
		{
			return -1;
		}
		
		public function get sampledPoints():Vector.<SamplePoint>
		{
			return _sampledPoints;
		}
		
		public function set minSamplesPerStep( value:PsykoParameter ):void
		{
			_minSamplesPerStep = value;
		}
		
		public function get minSamplesPerStep( ):PsykoParameter
		{
			return _minSamplesPerStep;
		}
		
		public function set outputStepSize( value:PsykoParameter ):void
		{
			_outputStepSize = value;
		}
		
		public function get outputStepSize( ):PsykoParameter
		{
			return _outputStepSize;
		}
		
		public function clear():void
		{
			PathManager.recycleSamplePoints(_sampledPoints);
			nextIndex = 0;
			_lastOutputIndex = 0;
		}
		
		public function addFirstPoint( p:Point, pressure:Number = -1, penButtonState:int = 0):void
		{
			clear();
			addPoint( p, pressure, penButtonState, true);
		}
		
		public function addPoint( p:Point, pressure:Number = -1, penButtonState:int = 0, force:Boolean = false ):Boolean
		{
			if ( !force && nextIndex > 0 && _sampledPoints[nextIndex-1].equals(p) ) 
			{
				return false;
			}
				
			_sampledPoints[nextIndex++] = PathManager.getSamplePoint( p, 0, 0, 0, pressure, penButtonState );
			return true;
		}
		
		public function addXY( x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0, force:Boolean = false ):Boolean
		{
			if ( !force && nextIndex > 0 && _sampledPoints[nextIndex-1].x == x && _sampledPoints[nextIndex-1].y == y ) 
			{
				return false;
			}
			
			_sampledPoints[nextIndex++] = PathManager.getSamplePointXY(x,y,0,0,0,pressure,penButtonState);
			return true;
		}
		
		public function addXYAt( index:int, x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0):void
		{
			if ( index > nextIndex ) index = nextIndex;
			if ( index < 0 ) index = 0;
			var p:SamplePoint = PathManager.getSamplePointXY(x,y,0,0,0,pressure,penButtonState);
			_sampledPoints.splice(index,0,p);
			nextIndex++;
			
		}
		
		public function addPointAt( index:int, point:Point, pressure:Number, penButtonState:int = 0 ):void
		{
			if ( index > nextIndex ) index = nextIndex;
			if ( index < 0 ) index = 0;
			var p:SamplePoint = PathManager.getSamplePoint(point,0,0,0,pressure,penButtonState);
			_sampledPoints.splice(index,0,p);
			nextIndex++;
			
		}
		
		public function getPointAt( index:int ):SamplePoint
		{
			index = (( index % nextIndex ) + nextIndex)% nextIndex;
			return _sampledPoints[index];
		}
		
		
		public function removePointAt(index:int ):void
		{
			PathManager.recycleSamplePoint( _sampledPoints[index] );
			_sampledPoints.splice(index,1);
			nextIndex--;
		}
		
		public function renderPath( g:Graphics, startIndex:int = 0, count:int = -1 ):int
		{
			if ( nextIndex > 1 && startIndex < nextIndex )
			{
				if ( count == -1 ) count = nextIndex - startIndex - 1;
				var p:SamplePoint = _sampledPoints[startIndex];
				g.moveTo(p.x, p.y );
				while ( (++startIndex < nextIndex)  && (count-- > 0))
				{
					p = _sampledPoints[startIndex];
					g.lineTo(p.x,p.y);
				}
			}
			return startIndex;
		}
		
		public function renderPoints( g:Graphics, startIndex:int = 0, count:int = -1 ):int
		{
			if ( nextIndex > 0 && startIndex < nextIndex )
			{
				if ( count == -1 ) count = nextIndex - startIndex;
				var p:SamplePoint = _sampledPoints[startIndex];
				while ( count > 0)
				{
					g.drawRect(int(p.x-3),int(p.y-3),5,5);
					if ( ++startIndex < nextIndex )
						p = _sampledPoints[startIndex];
					else 
						break;
					count--;
				}
			}
			return startIndex;
		}
		
		public function clone( startIndex:int = 0, count:int = -1 ):IPathEngine
		{
			var result:IPathEngine = PathManager.getPathEngine(type);
			if ( startIndex < 0 ) startIndex = 0;
			if ( startIndex < nextIndex )
			{
				if ( count == -1 ) count = nextIndex - startIndex;
				var p:SamplePoint = _sampledPoints[startIndex];
				while ( count > 0)
				{
					result.addXY(p.x,p.y,p.pressure,p.penButtonState, true);
					if ( ++startIndex < nextIndex )
						p = _sampledPoints[startIndex];
					else 
						break;
					count--;
				}
			}
			
			return result;
		}
		
		public function get pointCount():int
		{
			return nextIndex;
		}
		
		public function get sendTaps():Boolean
		{
			return _sendTaps;
		}
		
		public function set sendTaps(value:Boolean):void
		{
			_sendTaps = value;
		}
		
		public function update(forceUpdate : Boolean = false) :Vector.<SamplePoint>
		{
			throw("Override this");
			return null;
		}
		
		public function updateParametersFromXML(message:XML):void
		{
			for ( var j:int = 0; j < message.parameter.length(); j++ )
			{
				var parameter:XML = message.parameter[j];
				var parameterID:String = String( parameter.@id );
				for ( var i:int = 0; i < _parameters.length; i++ )
				{
					if( _parameters[i].id == parameterID )
					{
						_parameters[i].updateValueFromXML(parameter);
					}
				}
			}
		}
		
		public function getParameterSet( path:Array ):XML
		{
			var result:XML = <pathengine type={type}/>;
			path.push( "pathengine" );
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
	}
}