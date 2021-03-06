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
	import com.quasimondo.geom.ColorMatrix;
	
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManagerCallbackInfo;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	
	
	final public class BumpDecorator extends AbstractPointDecorator
	{
		
		public static const PARAMETER_N_SHININESS : String = "Shininess";
		public static const PARAMETER_N_GLOSSINESS : String = "Glossiness";
		public static const PARAMETER_N_BUMPINESS : String = "Bumpiness";
		public static const PARAMETER_N_BUMPINESS_RANGE : String = "Bumpiness Range";
		public static const PARAMETER_N_BUMP_INFLUENCE : String = "Bump Influence";
		static public const PARAMETER_SL_MODE:String = "Mode";
		static public const PARAMETER_NR_FACTOR:String = "Factor";
		static public const PARAMETER_SL_MAPPING:String = "Mapping";
		static public const PARAMETER_B_INVERT_MAPPING:String = "Invert Mapping";
		static public const PARAMETER_N_MAXIMUM_SPEED:String  = "Maximum Speed";
		static public const PARAMETER_N_NO_BUMP_PROB:String  = "No Bump Probability";
		static public const PARAMETER_N_MIN_BUMP:String  = "Min Bump value";
		static public const PARAMETER_N_MAX_BUMP:String  = "Max Bump value";
		
		static public const INDEX_MODE_FIXED:int = 0;
		static public const INDEX_MODE_SPEED:int = 1;
		static public const INDEX_MODE_PRESSURE:int = 2;
		static public const INDEX_MODE_PRESSURE_SPEED:int = 3;
		static public const INDEX_MODE_MULTIPLY:int = 4;
		static public const INDEX_MODE_ADD:int = 5;
		static public const INDEX_MODE_RANDOM:int = 6;
		
		private const _applyArray:Array = [0,0,1,1];
		
		//"Glossiness" - NumberValue
		public var param_glossiness:PsykoParameter;
		
		//"Bumpiness" - NumberValue
		public var param_bumpiness:PsykoParameter;
		
		//"Bumpiness Range" - NumberValue
		//sets a range of how the bumpiness will change based on the param_mappingMode
		public var param_bumpinessRange:PsykoParameter;
		
		//"Bump Influence" - NumberValue
		public var param_bumpInfluence:PsykoParameter;
		
		//"Mode" - StringListValue
	    //Sets which factor influences the bumpiness, the following indices are available:
		//0 - "Fixed" - uses a fixed value of 0.5
		//1 - "Speed" - painting speed
		//2 - "Pressure" - pen pressure
		//3 - "Automatic" - if pressure is available it will be used, if not speed will be used
		//4 - "Multiply" - the incoming bump value will be mutiplied with a random value within the range
		//5 - "Add" - the incoming bump value will be added to a random value within the range
		//6 - "Random" - a random value within the range
		public var param_mappingMode:PsykoParameter;
		
		//"Factor" - NumberRangeValue
		//brings the incoming bumpiness value into a given range
		public var param_mappingFactor:PsykoParameter;
		
		//"Mapping" - StringListValue
		//applies a tweening mapping function on the incoming bump values to shape 
		public var param_mappingFunction:PsykoParameter;
		
		//"Invert Mapping" - Boolean Value
		//if true inverts the mapping function big values -> small result, small values -> big result
		public var param_invertMapping:PsykoParameter;
		
		//"No Bump Probability" - NumberValue
		//sets a chance that a given point will cause no bump at all
		public var param_noBumpProbability:PsykoParameter;
		
		//"Maximum Speed" - NumberValue
		//sets the maximum expected drawing speed, used to tweak speed based results to the right range
		public var param_maxSpeed:PsykoParameter;
		
		// "Min Bump value" - NumberValue
		//used to clamp the final bump value to a limited range
		private var param_minBump:PsykoParameter;
		
		// "Max Bump value" - NumberValue
		//used to clamp the final bump value to a limited range
		private var param_maxBump:PsykoParameter;
		
		public function BumpDecorator()
		{
			super();
			
			param_mappingMode  	 = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MODE,0,["Fixed","Speed","Pressure","Automatic","Multiply","Add","Random"]);
			param_mappingFactor   = new PsykoParameter( PsykoParameter.NumberRangeParameter,PARAMETER_NR_FACTOR,0,1,0,1);
			param_mappingFunction   = new PsykoParameter( PsykoParameter.StringListParameter,PARAMETER_SL_MAPPING,0,mappingFunctionLabels);
			param_invertMapping   = new PsykoParameter( PsykoParameter.BooleanParameter,PARAMETER_B_INVERT_MAPPING,0);
			param_maxSpeed   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAXIMUM_SPEED,20,1,100);
			//MINIMUM BUMP VALUE: ex: can't go under 0
			param_minBump   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MIN_BUMP,0,-5,5);
			param_maxBump   		= new PsykoParameter( PsykoParameter.NumberParameter,PARAMETER_N_MAX_BUMP,5,-5,5);
			
			param_glossiness    = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_GLOSSINESS, 0.4, 0.01, 5);
			param_bumpiness     = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_BUMPINESS, 1, -10, 10 );
			param_bumpinessRange  = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_BUMPINESS_RANGE, 0.2, 0, 10 );
			param_bumpInfluence = new PsykoParameter( PsykoParameter.NumberParameter,      PARAMETER_N_BUMP_INFLUENCE, 0.6, -5, 5 );
			param_noBumpProbability     = new PsykoParameter( PsykoParameter.NumberParameter, PARAMETER_N_NO_BUMP_PROB, 0.0, 0, 1 );
			_parameters.push( param_glossiness, param_bumpiness, param_bumpinessRange,param_bumpInfluence, param_mappingMode,param_mappingFactor,param_mappingFunction,param_invertMapping,param_maxSpeed,param_noBumpProbability);
			
		}
		
		override public function process(points:Vector.<SamplePoint>, manager:PathManager, fingerIsDown:Boolean):Vector.<SamplePoint>
		{
			var applyArray:Array = _applyArray;
			
			var mode:int = param_mappingMode.index;
			var minFactor:Number = param_mappingFactor.lowerRangeValue;
			var maxFactor:Number = param_mappingFactor.upperRangeValue;
			
			var mapping:Function = mappingFunctions[param_mappingFunction.index];
			var ms:Number = param_maxSpeed.numberValue;
			var inv:Boolean = param_invertMapping.booleanValue;
			var nbp:Number = param_noBumpProbability.numberValue;
			for ( var i:int = 0; i < points.length; i++ )
			{
				var point:SamplePoint = points[i];
				var bumpFactors:Vector.<Number> = point.bumpFactors;
				var bmp:Number = bumpFactors[1];
				
				
				if ( mode == INDEX_MODE_FIXED)
				{
					bmp = 0.5;
				} else if ( mode == INDEX_MODE_SPEED )
				{
					applyArray[0] = Math.min(point.speed,ms) / ms;
					bmp = mapping.apply( null, applyArray);
					if ( inv ) bmp = 1 -bmp;
					bmp = minFactor + bmp * (maxFactor - minFactor );
				}  else if ( mode == INDEX_MODE_PRESSURE )
				{
					if ( point.pressure > 0 )
					{
						applyArray[0] = point.pressure / 2000;
						bmp = mapping.apply( null, applyArray);
						if ( inv ) bmp = 1 - bmp;
						bmp = minFactor + bmp * (maxFactor - minFactor );
					} else {
						bmp = minFactor;
					}
				} else if ( mode == INDEX_MODE_PRESSURE_SPEED )
				{
					if ( point.pressure > 0 )
					{
						applyArray[0] = point.pressure / 2000;
						bmp = mapping.apply( null, applyArray);
					} else {
						applyArray[0] = Math.min(point.speed,ms) / ms;
						bmp = mapping.apply( null, applyArray);
					}
					if ( inv ) bmp = 1 - bmp;
					bmp = minFactor + bmp * (maxFactor - minFactor );
				}  else if ( mode == INDEX_MODE_MULTIPLY )
				{
					applyArray[0] = param_mappingFactor.randomValue;
					bmp *= mapping.apply( null, applyArray);
				} else if ( mode == INDEX_MODE_ADD )
				{
					applyArray[0] = param_mappingFactor.randomValue;
					bmp += mapping.apply( null, applyArray);
				}  else if ( mode == INDEX_MODE_RANDOM )
				{
					applyArray[0] = param_mappingFactor.randomValue;
					bmp = mapping.apply( null, applyArray);
				} 
				
				var bumpValue:Number=  (Math.random() < nbp)?param_bumpiness.numberValue: param_bumpiness.numberValue - param_bumpinessRange.numberValue + (  param_bumpinessRange.numberValue  * bmp )* 2;
					
					
				bumpFactors[0] = bumpFactors[4] = bumpFactors[8]  = bumpFactors[12] = param_glossiness.numberValue;
				//ADD CASE NO BUMP VALUE
				bumpFactors[1] = bumpFactors[5] = bumpFactors[9]  = bumpFactors[13] = Math.min(Math.max(bumpValue,param_minBump.numberValue),param_maxBump.numberValue);
				// IMPORTANT: bumpFactors[2] is reserved
				bumpFactors[3] = bumpFactors[7] = bumpFactors[11] = bumpFactors[15] = param_bumpInfluence.numberValue;
				

			}
			
			
			return points;
		}
		
		override public function getParameterSetAsXML( path:Array ):XML
		{
			var data:XML = <BumpDecorator />;
			for ( var i:int = 0; i < _parameters.length; i++ )
			{
				data.appendChild( _parameters[i].toXML(path) );
			}
			return data;
		}
		
	}
}