package net.psykosoft.psykopaint2.core.drawing.paths.decorators
{
	import com.greensock.easing.Circ;
	import com.greensock.easing.CircQuad;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Strong;
	
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	public class AbstractPointDecorator implements IPointDecorator
	{
		
		static protected const mappingFunctions:Vector.<Function> = Vector.<Function>([
			Linear.easeNone,
			CircQuad.easeIn,
			Circ.easeIn,
			Sine.easeIn,
			Quad.easeIn, 
			Cubic.easeIn, 
			Quart.easeIn, 
			Quint.easeIn,
			Strong.easeIn,
			Expo.easeIn,
			CircQuad.easeOut,
			Circ.easeOut,
			Sine.easeOut,
			Quad.easeOut, 
			Cubic.easeOut, 
			Quart.easeOut, 
			Quint.easeOut,
			Strong.easeOut,
			Expo.easeOut,
			CircQuad.easeInOut,
			Circ.easeInOut,
			Sine.easeInOut,
			Quad.easeInOut, 
			Cubic.easeInOut, 
			Quart.easeInOut, 
			Quint.easeInOut,
			Strong.easeInOut,
			Expo.easeInOut
		]);
		
		
		static protected const mappingFunctionLabels:Vector.<String> = Vector.<String>(
		["Linear",
		"CircQuadIn",
		"CircularIn",
		"SineIn",
		"QuadraticIn",
		"CubicIn",
		"QuarticIn",
		"QuinticIn",
		"StrongIn",
		"ExpoIn",
		"CircQuadOut",
		"CircularOut",
		"SineOut",
		"QuadraticOut",
		"CubicOut",
		"QuarticOut",
		"QuinticOut",
		"StrongOut",
		"ExpoOut",
		"CircQuadInOut",
		"CircularInOut",
		"SineInOut",
		"QuadraticInOut",
		"CubicInOut",
		"QuarticInOut",
		"QuinticInOut",
		"StrongInOut",
		"ExpoInOut"]);
		
		protected var _parameters:Vector.<PsykoParameter>;
		protected var _active:Boolean;
		
		public function AbstractPointDecorator()
		{
			_parameters = new Vector.<PsykoParameter>();
			_active = true;
		}
		
		public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			throw("override this");
			return null;
		}
		
		public function compare( points:Vector.<SamplePoint>, manager:PathManager ):Vector.<Vector.<SamplePoint>>
		{
			var result:Vector.<Vector.<SamplePoint>> = new Vector.<Vector.<SamplePoint>>(2,true);
			result[0] = points;
			return result;
		}
		
		public function getParameterSetAsXML( path:Array ):XML
		{
			throw("override this");
			return null;
		}
		
		public function getParameterSet( vo:ParameterSetVO, showInUiOnly:Boolean  ):void
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( !showInUiOnly || _parameters[i].showInUI > -1 )
					vo.parameters.push( _parameters[i] );
			}
			
		}
		
		public function updateParametersFromXML(message:XML):void
		{
			if ( message.hasOwnProperty("@active"))
			{
				active = int(message.@active) != 0;	
			}
			for ( var j:int = 0; j < message.parameter.length(); j++ )
			{
				var parameter:XML = message.parameter[j];
				var parameterID:String = String( parameter.@id );
				for ( var i:int = 0; i < _parameters.length; i++ )
				{
					if( _parameters[i].id == parameterID )
					{
						_parameters[i].updateValueFromXML(parameter);
						break;
					}
				}
				if ( i == _parameters.length ) throw("AbstractPointDecorator: parameter id not found: "+parameterID);
			}
		}
		
		public function getParameterByPath(path:Array):PsykoParameter
		{
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				if ( _parameters[i].id == path[path.length -1] ) return  _parameters[i];
			}
			throw("AbstractPointDecorator.getParameterByPath parameter not found: "+path.join("."));
			
			return null;
			
		}
		
		public function hasActivePoints():Boolean
		{
			return false;
		}
		
		public function clearActivePoints():void
		{
			
		}
		
		public function set active( value:Boolean ):void
		{
			_active = value;
		}
		
		public function get active():Boolean
		{
			return _active ;
		}
	}
}