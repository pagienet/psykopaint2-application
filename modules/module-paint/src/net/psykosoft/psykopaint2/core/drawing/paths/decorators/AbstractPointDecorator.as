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
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	public class AbstractPointDecorator implements IPointDecorator
	{
		static public const INDEX_MAPPING_LINEAR:int = 0;
		static public const INDEX_MAPPING_CIRCQUAD_IN:int = 1;
		static public const INDEX_MAPPING_CIRCULAR_IN:int = 2;
		static public const INDEX_MAPPING_SINE_IN:int = 3;
		static public const INDEX_MAPPING_QUADRATIC_IN:int =4;
		static public const INDEX_MAPPING_CUBIC_IN:int = 5;
		static public const INDEX_MAPPING_QUARTIC_IN:int = 6;
		static public const INDEX_MAPPING_QUINTIC_IN:int = 7;
		static public const INDEX_MAPPING_STRONG_IN:int = 8;
		static public const INDEX_MAPPING_EXPONENTIAL_IN:int = 9;
		static public const INDEX_MAPPING_CIRCQUAD_OUT:int = 10;
		static public const INDEX_MAPPING_CIRCULAR_OUT:int = 11;
		static public const INDEX_MAPPING_SINE_OUT:int = 12;
		static public const INDEX_MAPPING_QUADRATIC_OUT:int =13;
		static public const INDEX_MAPPING_CUBIC_OUT:int = 14;
		static public const INDEX_MAPPING_QUARTIC_OUT:int = 15;
		static public const INDEX_MAPPING_QUINTIC_OUT:int = 16;
		static public const INDEX_MAPPING_STRONG_OUT:int = 17;
		static public const INDEX_MAPPING_EXPONENTIAL_OUT:int = 18;
		static public const INDEX_MAPPING_CIRCQUAD_INOUT:int = 19;
		static public const INDEX_MAPPING_CIRCULAR_INOUT:int = 20;
		static public const INDEX_MAPPING_SINE_INOUT:int = 21;
		static public const INDEX_MAPPING_QUADRATIC_INOUT:int =22;
		static public const INDEX_MAPPING_CUBIC_INOUT:int = 23;
		static public const INDEX_MAPPING_QUARTIC_INOUT:int = 24;
		static public const INDEX_MAPPING_QUINTIC_INOUT:int = 25;
		static public const INDEX_MAPPING_STRONG_INOUT:int = 26;
		static public const INDEX_MAPPING_EXPONENTIAL_INOUT:int = 27;
		
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
		
		protected const _scalingFactor:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
		
		
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