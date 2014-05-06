package net.psykosoft.psykopaint2.core.drawing.paths
{
	import flash.display.Graphics;
	
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;

	public class AbstractPathEngine implements IPathEngine
	{
		public static const PARAMETER_MIN_SAMPLES:String = "Minimum Samples Per Step";
		public static const PARAMETER_OUTPUT_STEP:String = "Output Step Size";
		public static const PARAMETER_SEND_TAPS:String = "Send Taps";
		public static const PARAMETER_SPEED_SMOOTHING:String = "Speed Smoothing";
		
		
		protected var _sampledPoints:Vector.<SamplePoint>;
		protected var nextIndex:int;
		protected var _lastOutputIndex : int;
		
		protected var _minSamplesPerStep : PsykoParameter;
		protected var _outputStepSize:PsykoParameter;
		protected var _sendTaps:PsykoParameter;
		protected var _speedSmoothing:PsykoParameter;
		
		private var _parameters:Vector.<PsykoParameter>;
		
		public function AbstractPathEngine()
		{
			init();
		}
		
		protected function init():void
		{
			_sampledPoints = new Vector.<SamplePoint>();
			nextIndex = 0;
			_minSamplesPerStep = new PsykoParameter( PsykoParameter.IntParameter,PARAMETER_MIN_SAMPLES,1,1,10);
			_outputStepSize = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_OUTPUT_STEP,2,0.05,2000);
			_sendTaps = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_SEND_TAPS,false);
			_speedSmoothing = new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_SPEED_SMOOTHING,0.9,0,1);
			_parameters = new Vector.<PsykoParameter>();
			_parameters.push(_minSamplesPerStep,_outputStepSize, _sendTaps,_speedSmoothing);
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
		
		public function set speedSmoothing( value:PsykoParameter ):void
		{
			_speedSmoothing = value;
		}
		
		public function get speedSmoothing( ):PsykoParameter
		{
			return _speedSmoothing;
		}
		
		
		public function clear():void
		{
			PathManager.recycleSamplePoints(_sampledPoints);
			nextIndex = 0;
			_lastOutputIndex = 0;
		}
		
		public function addFirstPoint( x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0):void
		{
			clear();
			addPoint(x, y, pressure, penButtonState, true, true);
		}
		
		public function addPoint( x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0, force:Boolean = false, first:Boolean = false ):Boolean
		{
			if ( !force && nextIndex > 0 && _sampledPoints[int(nextIndex-1)].x == x && _sampledPoints[int(nextIndex-1)].y == y) 
			{
				return false;
			}
				
			_sampledPoints[nextIndex++] = PathManager.getSamplePoint( x,y, 0, 0, 0, 0, pressure, penButtonState, null, null, first );
			return true;
		}
		
		public function addSamplePoint( p:SamplePoint, force:Boolean = false ):Boolean
		{
			if ( !force && nextIndex > 0 && _sampledPoints[int(nextIndex-1)].x == p.x && _sampledPoints[int(nextIndex-1)].y == p.y) 
			{
				return false;
			}
			
			_sampledPoints[nextIndex++] = p;
			return true;
		}
		
		public function addXYAt( index:int, x:Number, y:Number, pressure:Number = -1, penButtonState:int = 0):void
		{
			if ( index > nextIndex ) index = nextIndex;
			if ( index < 0 ) index = 0;
			var p:SamplePoint = PathManager.getSamplePoint(x,y,0,0,0,0,pressure,penButtonState);
			_sampledPoints.splice(index,0,p);
			nextIndex++;
			
		}
		
		public function addPointAt( index:int, x:Number, y:Number, pressure:Number, penButtonState:int = 0 ):void
		{
			if ( index > nextIndex ) index = nextIndex;
			if ( index < 0 ) index = 0;
			var p:SamplePoint = PathManager.getSamplePoint(x,y,0,0,0,pressure,penButtonState);
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
				//var p:SamplePoint = _sampledPoints[startIndex];
				while ( count > 0)
				{
					result.addSamplePoint( _sampledPoints[startIndex++].getClone(), true);
					//result.addPoint(p.x,p.y,p.pressure,p.penButtonState, true);
					//if ( ++startIndex == nextIndex )
					//	break;
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
			return _sendTaps.booleanValue;
		}
		
		public function set sendTaps(value:Boolean):void
		{
			_sendTaps.booleanValue = value;
		}
		
		public function update(result:Vector.<SamplePoint>, forceUpdate : Boolean = false) :void
		{
			throw("Override this");
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
		
		public function getParameterSetAsXML( path:Array ):XML
		{
			var result:XML = <pathengine type={type}/>;
			path.push( "pathengine" );
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				result.appendChild( _parameters[i].toXML(path) );
			}
			return result;
		}
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean ):void
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( !showInUiOnly || _parameters[i].showInUI > -1 )
					vo.parameters.push( _parameters[i] );
			}
		}
		
		public function getParameterByPath(path:Array ):PsykoParameter
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( _parameters[i].id == path[path.length -1] ) return  _parameters[i];
			}
			throw("AbstractPathEngine.getParameterByPath parameter not found: "+path.join("."));
			
			return null;
		}
	}
}